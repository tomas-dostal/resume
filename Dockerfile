###### Convert jsonresume to html ######

FROM alpine as build-stage
LABEL name=build-stage

WORKDIR /app

COPY img.webp .
COPY resume.json .
COPY .git .git

RUN apk --no-cache add git npm icu-data-full gawk
RUN apk add --update nodejs npm
RUN npm install -g yarn
RUN yarn add jsonresume-theme-elegant jsonresume-theme-elegant-pdf

RUN npm init -y
RUN export PUPPETEER_SKIP_DOWNLOAD="1" && npm install -g resume-cli --unsafe-perm --allow-root
RUN resume export index.html --resume resume.json --theme elegant
RUN sed -i 's#+420 605 066 470#<a class="link-disguise" href="tel:+420605066470" itemprop="phone">+420 605 066 470</a>#g' index.html  && sed -i 's#<a href="https://dostál.eu"#<a class="link-disguise" href="https://dostál.eu"#g' index.html && sed -i 's#//unpkg.com#https://unpkg.com#g' index.html && sed -i 's#img.webp#img.png#g' index.html
RUN TMP=$(git log -1 --date=format:"%Y/%m/%d %T" --pretty='format:%h (%ad)') && sed -i ':a;N;$!ba;s/\n/ /g' index.html && sed -i "s,<\/section>,$TMP,2" index.html

###### Create a PDF ######

FROM  surnet/alpine-wkhtmltopdf:3.17.0-0.12.6-small as build-stage-pdf
#RUN apk add --no-cache fontconfig && fc-cache -f
WORKDIR /app
COPY img.png .

COPY --from=build-stage /app/index.html .
RUN export XDG_RUNTIME_DIR="/app/" && /bin/wkhtmltopdf index.html --enable-local-file-access --enable-external-links --allow img.png - > cv.pdf ; exit 0

###### Serve resume html & PDF ######

FROM nginx
LABEL name=resume

COPY ./nginx.conf /etc/nginx/nginx.conf

WORKDIR /app/static
COPY --from=build-stage /app/index.html .
COPY img.png .
COPY --from=build-stage-pdf /app/cv.pdf .
CMD ["nginx", "-g", "daemon off;"]
