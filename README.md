# Isajjim Infra

Isajjim AI 서버를 위한 GCP 인프라 Terraform 코드입니다.

현재 인프라는 GCP에 AI 전용 VM, VPC, 방화벽, Secret Manager, Artifact Registry, GitHub Actions Workload Identity Federation을 구성합니다. 백엔드 서버와 스토리지는 사양 확정 후 별도로 구성합니다.

## 아키텍처

```text
GitHub Actions
  -> Workload Identity Federation
  -> Artifact Registry push
  -> IAP SSH deploy
  -> GCE AI VM

Backend
  -> HTTP request to AI VM :8000

GCE AI VM
  -> Docker container
  -> Secret Manager: AUTH_TOKEN, HF_TOKEN
  -> Artifact Registry pull
```

## 관리 리소스

- Compute Engine AI VM
  - 머신 타입: `g2-standard-4`
  - GPU: NVIDIA L4
  - OS: Ubuntu 24.04 LTS
  - 부트 디스크: 100GB `pd-balanced`
  - 시작 스크립트로 Docker, NVIDIA 드라이버, NVIDIA Container Toolkit 설치
- AI 전용 VPC와 서브넷
  - VPC: `${project_name}-ai-vpc`
  - 서브넷 CIDR 기본값: `10.10.0.0/24`
- 방화벽 규칙
  - SSH: IAP 전용, `35.235.240.0/20`, TCP `22`
  - AI API: 기본값 `0.0.0.0/0`, TCP `8000`
- AI VM용 고정 외부 IP
- AI VM 서비스 계정
- Secret Manager secrets
  - `${project_name}-ai-auth-token`
  - `${project_name}-ai-hf-token`
- Artifact Registry Docker 저장소
- GitHub Actions 서비스 계정과 OIDC provider

## 저장소 구조

```text
terraform/
  environments/
    gcp/                 # GCP 환경 진입점
  modules/
    gcp/
      compute/           # AI VM
      github_actions/    # Workload Identity Federation 및 배포 IAM
      iam/               # AI VM 서비스 계정
      networking/        # VPC, 서브넷, IP, 방화벽
      registry/          # Artifact Registry
      secrets/           # Secret Manager secret 및 IAM
terraform.tfvars.example
```

## 사전 준비

- Terraform `>= 1.5.0`
- Google Cloud CLI
- 결제가 활성화된 GCP 프로젝트
- `asia-northeast3-a` 리전/존에서 `g2-standard-4` 사용 가능 quota
- Compute Engine, IAM, Secret Manager, Artifact Registry, IAP, STS, Service Account Credentials 관리 권한
- Application Default Credentials 설정:

```bash
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

## 설정

로컬 변수 파일을 생성합니다.

```bash
cp terraform.tfvars.example terraform.tfvars
```

예시:

```hcl
project_name = "isajjim"
project_id   = "knu-2026-agion427"

ai_machine_type = "g2-standard-4"
ai_disk_size_gb = 100
ai_subnet_cidr  = "10.10.0.0/24"

ai_allowed_source_ranges = ["0.0.0.0/0"]
```

개발 환경에서는 `8000` 포트를 `0.0.0.0/0`으로 열어둘 수 있습니다. 운영 환경에서는 백엔드 서버의 고정 egress IP 대역으로 좁히는 것을 권장합니다.

## 적용

```bash
terraform -chdir=terraform/environments/gcp init
terraform -chdir=terraform/environments/gcp validate
terraform -chdir=terraform/environments/gcp plan \
  -var-file=../../../terraform.tfvars
terraform -chdir=terraform/environments/gcp apply \
  -var-file=../../../terraform.tfvars
```

`terraform.tfvars`를 사용하지 않는 경우 변수를 직접 전달할 수 있습니다.

```bash
terraform -chdir=terraform/environments/gcp apply \
  -var='project_id=<PROJECT_ID>' \
  -var='project_name=<PROJECT_NAME>'
```

## 시크릿

Terraform은 Secret Manager secret 리소스만 생성하고, 실제 secret 값은 Terraform state에 저장하지 않습니다.

`apply` 이후 secret 값을 직접 주입합니다.

```bash
printf '%s' '<AUTH_TOKEN>' | gcloud secrets versions add isajjim-ai-auth-token --data-file=-
printf '%s' '<HF_TOKEN>' | gcloud secrets versions add isajjim-ai-hf-token --data-file=-
```

secret 값을 출력하지 않고 version이 생성되었는지만 확인합니다.

```bash
gcloud secrets versions list isajjim-ai-auth-token
gcloud secrets versions list isajjim-ai-hf-token
```

## GitHub Actions 연동

Terraform은 아래 GitHub 저장소와 브랜치를 허용하는 GitHub Actions 서비스 계정과 Workload Identity Provider를 생성합니다.

- 저장소: `FitTruck/boxer-Isajjim`
- 브랜치: `main`

AI 애플리케이션 workflow에서는 Terraform output 값을 사용합니다.

```bash
terraform -chdir=terraform/environments/gcp output
```

주요 output:

- `artifact_registry_url`
- `github_actions_sa_email`
- `workload_identity_provider`
- `ai_instance_name`
- `ai_external_ip`

배포 workflow는 IAP SSH로 VM에 접속한 뒤 Artifact Registry에서 이미지를 pull하고, Secret Manager에서 런타임 secret을 읽어 Docker 컨테이너를 `8000` 포트로 실행합니다.

## VM 접속

SSH는 IAP를 통해서만 허용됩니다.

```bash
gcloud compute ssh isajjim-ai \
  --zone=asia-northeast3-a \
  --tunnel-through-iap
```

VM은 조직 외부 사용자도 콘솔 SSH를 사용할 수 있도록 OS Login을 비활성화하고
메타데이터 기반 SSH 키를 사용합니다. 콘솔과 `gcloud compute ssh`가 추가하는
`ssh-keys` 메타데이터는 Terraform이 삭제하지 않도록 변경 감지에서 제외합니다.

## 운영 확인

시작 스크립트 로그 확인:

```bash
sudo tail -f /var/log/ai-startup-script.log
```

GPU 확인:

```bash
nvidia-smi
sudo docker run --rm --gpus all nvidia/cuda:12.4.1-base-ubuntu22.04 nvidia-smi
```

배포된 컨테이너 확인:

```bash
sudo docker ps
sudo docker logs -f boxer-isajjim
```

포트 점유 확인:

```bash
sudo docker ps --filter "publish=8000"
sudo ss -ltnp 'sport = :8000'
```

## 주의사항

- Terraform state는 기본적으로 로컬에서 관리됩니다. state 파일을 잃어버리거나 Git에 커밋하지 않도록 주의합니다.
- secret 값은 의도적으로 Terraform 밖에서 관리합니다.
- AI API 방화벽은 개발 편의를 위해 기본값이 전체 CIDR 허용입니다. 운영 전에는 접근 대역을 제한해야 합니다.
- VM 부트 디스크는 `auto_delete = true`로 구성되어 있습니다. VM을 삭제하면 부트 디스크도 함께 삭제됩니다.
