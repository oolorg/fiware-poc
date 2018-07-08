FROM ubuntu:xenial

RUN apt update -y && \
  apt install -y npm nginx git && \
  npm install bower -g && \
  echo "daemon off;" >> /etc/nginx/nginx.conf && \
  cd /var/www/html && \
  git clone https://github.com/telefonicaid/fiware-sth-graphs.git && \
  cp -rp fiware-sth-graphs/examples/jquery/* . && \
  cp -p fiware-sth-graphs/bower.json . && \
  ln -s /usr/bin/nodejs /usr/bin/node && \
  bower install --allow-root
  
COPY graph/lineChart.html /var/www/html/lineChart.html
COPY graph/lineChart.js /var/www/html/lineChart.js
COPY graph/default /etc/nginx/sites-available/default

EXPOSE 81

CMD ["nginx"]
