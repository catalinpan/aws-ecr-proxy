FROM nginx:1.17.7-alpine

RUN apk -v --update add \
        python \
        py-pip \
        && \
    pip install --upgrade pip awscli==1.11.92 && \
    apk -v --purge del py-pip && \
    rm /var/cache/apk/*

ADD configs/nginx/ssl /etc/nginx/ssl
ADD configs/nginx/*.conf /etc/nginx/
ADD configs/*.sh /

EXPOSE 80 443

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
