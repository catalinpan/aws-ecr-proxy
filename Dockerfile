FROM nginx:1.18.0-alpine

RUN apk add --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/v3.12/community \
    aws-cli

ADD configs/nginx/nginx.conf /etc/nginx/nginx.conf
ADD configs/nginx/ssl /etc/nginx/ssl

ADD configs/entrypoint.sh /entrypoint.sh
ADD configs/auth_update.sh /auth_update.sh
ADD configs/renew_token.sh /renew_token.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
