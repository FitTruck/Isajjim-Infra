#!/bin/bash
set -euo pipefail
exec >> /var/log/startup-script.log 2>&1
echo "[$(date)] Startup script started"

# ---- 패키지 설치 (최초 1회) ----
if ! command -v docker &>/dev/null; then
  echo "[$(date)] Docker 설치 중..."
  apt-get update -y
  apt-get install -y docker.io
  systemctl enable docker
  systemctl start docker
  usermod -aG docker ubuntu
fi

if ! command -v nginx &>/dev/null; then
  echo "[$(date)] Nginx 설치 중..."
  apt-get install -y nginx certbot python3-certbot-nginx
fi

# ---- Secret Manager에서 시크릿 가져오기 ----
echo "[$(date)] Secret Manager에서 시크릿 로드 중..."
DB_PASSWORD=$(gcloud secrets versions access latest --secret="db-password" --project="${project_id}")
GEMINI_API_KEY=$(gcloud secrets versions access latest --secret="gemini-api-key" --project="${project_id}")
JWT_SECRET=$(gcloud secrets versions access latest --secret="jwt-secret" --project="${project_id}" 2>/dev/null || echo "dev-jwt-secret-change-before-prod")
APP_ENCRYPTION_KEY=$(gcloud secrets versions access latest --secret="app-encryption-key" --project="${project_id}" 2>/dev/null || echo "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=")
AUTH_TOKEN=$(gcloud secrets versions access latest --secret="auth-token" --project="${project_id}" 2>/dev/null || echo "dev-auth-token-change-before-prod")
KAKAO_CLIENT_ID=$(gcloud secrets versions access latest --secret="kakao-client-id" --project="${project_id}" 2>/dev/null || echo "dev-kakao-client-id")
KAKAO_CLIENT_SECRET=$(gcloud secrets versions access latest --secret="kakao-client-secret" --project="${project_id}" 2>/dev/null || echo "dev-kakao-client-secret")
KAKAO_ADMIN_KEY=$(gcloud secrets versions access latest --secret="kakao-admin-key" --project="${project_id}" 2>/dev/null || echo "dev-kakao-admin-key")
GOOGLE_CLIENT_ID=$(gcloud secrets versions access latest --secret="google-client-id" --project="${project_id}" 2>/dev/null || echo "dev-google-client-id")
GOOGLE_CLIENT_SECRET=$(gcloud secrets versions access latest --secret="google-client-secret" --project="${project_id}" 2>/dev/null || echo "dev-google-client-secret")
NAVER_CLIENT_ID=$(gcloud secrets versions access latest --secret="naver-client-id" --project="${project_id}" 2>/dev/null || echo "dev-naver-client-id")
NAVER_CLIENT_SECRET=$(gcloud secrets versions access latest --secret="naver-client-secret" --project="${project_id}" 2>/dev/null || echo "dev-naver-client-secret")

JWT_ACCESS_TOKEN_EXPIRATION_TIME="604800000"
JWT_REFRESH_TOKEN_EXPIRATION_TIME="604800000"
JWT_REFRESH_TOKEN_REISSUE_LIMIT_DAYS="14"

# ---- Docker 인증 및 최신 이미지 pull ----
echo "[$(date)] Docker 이미지 pull 중..."
gcloud auth configure-docker ${region}-docker.pkg.dev --quiet
docker pull ${region}-docker.pkg.dev/${project_id}/isajjim-repo/backend:latest

# ---- Redis 컨테이너 실행 (없을 경우에만) ----
if ! docker ps --filter "name=redis" --filter "status=running" | grep -q redis; then
  echo "[$(date)] Redis 컨테이너 시작 중..."
  docker stop redis 2>/dev/null || true
  docker rm redis 2>/dev/null || true
  docker run -d \
    --name redis \
    --network host \
    --restart unless-stopped \
    redis:latest
fi

# ---- 기존 컨테이너 정리 ----
docker stop isajjim-backend 2>/dev/null || true
docker rm isajjim-backend 2>/dev/null || true

# ---- 컨테이너 실행 (시크릿을 환경변수로 직접 주입, 파일 저장 없음) ----
echo "[$(date)] 컨테이너 실행 중..."
docker run -d \
  --name isajjim-backend \
  -e SPRING_PROFILES_ACTIVE=dev \
  -e "DB_URL=jdbc:mysql://${db_private_ip}:3306/isajjim" \
  -e DB_USERNAME=isajjim-user \
  -e DB_PASSWORD="$DB_PASSWORD" \
  -e GEMINI_API_KEY="$GEMINI_API_KEY" \
  -e GEMINI_MODEL=gemini-2.0-flash \
  -e GOOGLE_PROJECT_ID="${project_id}" \
  -e GOOGLE_GCS_BUCKET="${images_bucket}" \
  -e FRONTEND_URL="${frontend_url}" \
  -e AI_BASE_URL=http://localhost:8000 \
  -e AI_USE_SERVER=false \
  -e ESTIMATE_EXTRA_VOLUME_RATIO=1.1 \
  -e "DEV_SWAGGER_URL=https://${api_domain}" \
  -e "DEV_BASE_URL=https://${api_domain}" \
  -e MAIN_PAGE=/ \
  -e LOGIN_FAIL_PAGE=/ \
  -e LOCAL_URL=http://localhost:3000 \
  -e LOCAL_SECURE_URL=https://localhost:3000 \
  -e JWT_SECRET="$JWT_SECRET" \
  -e JWT_ACCESS_TOKEN_EXPIRATION_TIME="$JWT_ACCESS_TOKEN_EXPIRATION_TIME" \
  -e JWT_REFRESH_TOKEN_EXPIRATION_TIME="$JWT_REFRESH_TOKEN_EXPIRATION_TIME" \
  -e JWT_REFRESH_TOKEN_REISSUE_LIMIT_DAYS="$JWT_REFRESH_TOKEN_REISSUE_LIMIT_DAYS" \
  -e APP_ENCRYPTION_KEY="$APP_ENCRYPTION_KEY" \
  -e AUTH_TOKEN="$AUTH_TOKEN" \
  -e KAKAO_CLIENT_ID="$KAKAO_CLIENT_ID" \
  -e KAKAO_CLIENT_SECRET="$KAKAO_CLIENT_SECRET" \
  -e KAKAO_ADMIN_KEY="$KAKAO_ADMIN_KEY" \
  -e GOOGLE_CLIENT_ID="$GOOGLE_CLIENT_ID" \
  -e GOOGLE_CLIENT_SECRET="$GOOGLE_CLIENT_SECRET" \
  -e NAVER_CLIENT_ID="$NAVER_CLIENT_ID" \
  -e NAVER_CLIENT_SECRET="$NAVER_CLIENT_SECRET" \
  --network host \
  --restart unless-stopped \
  ${region}-docker.pkg.dev/${project_id}/isajjim-repo/backend:latest

echo "[$(date)] Startup script completed"
