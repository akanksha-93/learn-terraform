FROM public.ecr.aws/nginx/nginx:1.25.0

COPY build /usr/share/nginx/html/
COPY .env /usr/share/nginx/html/

COPY conf/conf.d/default.conf /etc/nginx/conf.d/

COPY env-config.js /usr/share/nginx/html/

COPY env.sh /tmp
RUN chmod +x /tmp/env.sh

EXPOSE 8080

CMD ["sh", "-c", "cd /usr/share/nginx/html && /tmp/env.sh && nginx -g \"daemon off;\""]