FROM python:3.9-slim
LABEL Jun Park <junpark4395@gmail.com>

ARG GIT_USERNAME=gitlab
ARG GIT_PASSWORD=password
ARG user=test
ARG group=test
ARG uid=1000
ARG gid=1000

ADD ./requirements.txt /webapp/server/requirements.txt
ADD ./conf /webapp/server/conf

RUN apt-get update \
    && apt-get install -y nginx gcc libmariadb-dev \
    && apt-get install -y logrotate \
    && mkdir -p /webapp/uwsgi \
    && mkdir -p /webapp/nginx \
    && mkdir -p /webapp/server \
    && groupadd -g ${gid} ${group} \
    && useradd -d /webapp/server -u ${uid} -g ${gid} -m -s /bin/bash ${user} \
    && pip install --no-cache-dir uwsgi pip --upgrade \
    && pip install --no-cache-dir -r /webapp/server/requirements.txt \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log \
    && rm -rf /var/lib/nginx \
    && ln -sf /webapp/nginx /var/lib/nginx \
    && rm -rf /webapp/server/requirements.txt

ADD . /webapp/server
WORKDIR /webapp/server

ENV NGINX_SET_REAL_IP_FROM="172.18.0.0/16"\
    UWSGI_SOCKET="/webapp/uwsgi/webapp.sock"\
    UWSGI_PID="/webapp/uwsgi/webapp.pid"\
    UWSGI_CHDIR="/webapp/server"\
    UWSGI_MODULE="asset_manager.wsgi"\
    RUNNING_ENV="local"

RUN mv ./conf/run.sh / \
    && chmod 755 /run.sh \
    && touch /run/nginx.pid \
    && chown -R ${uid}:${gid} /run/nginx.pid \
    && chown -R ${uid}:${gid} /webapp \
    && chown -R ${uid}:${gid} /etc/nginx \
    && mv ./conf/nginx.conf /etc/nginx/nginx.conf \
    && mv ./conf/webapp.conf /etc/nginx/conf.d/webapp.conf \
    && mv ./conf/uwsgi.ini /webapp/uwsgi/uwsgi.ini

USER ${user}
CMD ["/run.sh"]