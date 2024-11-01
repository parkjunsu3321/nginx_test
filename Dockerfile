# 1단계: 빌드 단계
FROM ubuntu:20.04 as builder

# 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential git zlib1g-dev libpcre3-dev libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# nginx, nginx-rtmp-module 다운
RUN git clone https://github.com/arut/nginx-rtmp-module.git && \
    git clone https://github.com/nginx/nginx.git

# nginx를 설치하고 nginx-rtmp-module 추가
RUN cd nginx && \
    ./auto/configure --add-module=../nginx-rtmp-module && \
    make && make install

# 2단계: Nginx 실행 단계
FROM ubuntu:20.04 as nginx

# ffmpeg 설치
RUN apt-get update && apt-get install -y ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 빌드된 파일 및 설정파일 복사
COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY nginx.conf /usr/local/nginx/conf/nginx.conf

# 포트 노출
EXPOSE 1935 8080

# 실행
ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]
