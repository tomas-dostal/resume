FROM alpine as build-stage
LABEL name=tomas-dostal/resume

WORKDIR /app

COPY img.webp .
COPY resume.json .
#COPY package-lock.json .

RUN apk --no-cache add  git npm
RUN npm init -y
RUN export PUPPETEER_SKIP_DOWNLOAD="1" && npm install -g resume-cli --unsafe-perm --allow-root
RUN npm install jsonresume-theme-elegant jsonresume-theme-elegant-pdf
RUN npm i -g puppeteer

RUN resume export index.html --resume resume.json --theme elegant
RUN sed -i 's#+420 605 066 470#<a class="link-disguise" href="tel:+420605066470" itemprop="phone">+420 605 066 470</a>#g' index.html  && sed -i 's#<a href="https://dostál.eu"#<a class="link-disguise" href="https://dostál.eu"#g' index.html

RUN puppeteer --margin-top 0 --margin-right 0 --margin-bottom 0 --margin-left 0 --no-sandbox --format A4 print index.html cv.pdf


FROM nginx

COPY ./nginx.conf /etc/nginx/nginx.conf

WORKDIR /app

COPY --from=build-stage /app/index.html /app/static
COPY --from=build-stage /app/img.webp /app/static
COPY --from=build-stage /app/cv.pdf /app/static
