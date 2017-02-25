FROM nginx:1.11.10-alpine

RUN apk -v --update add \
        python \
        py-pip \
        groff \
        less \
        mailcap \
        && \
    pip install --upgrade awscli s3cmd python-magic && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

ADD configs/nginx/nginx.conf /etc/nginx/nginx.conf
ADD configs/nginx/ssl /etc/nginx/ssl

ADD configs/entrypoint.sh /entrypoint.sh
ADD configs/auth_update.sh /auth_update.sh
ADD configs/renew_token.sh /renew_token.sh

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
