###### Convert jsonresume to html ######

FROM alpine as build-stage
LABEL name=build-stage

WORKDIR /app

COPY img.webp .
COPY resume.json .

RUN apk --no-cache add  git npm
#RUN apt update && apt install git npm wkhtmltopdf -y

RUN npm init -y

RUN export PUPPETEER_SKIP_DOWNLOAD="1" && npm install -g resume-cli --unsafe-perm --allow-root
RUN npm install jsonresume-theme-elegant jsonresume-theme-elegant-pdf

RUN resume export index.html --resume resume.json --theme elegant
# jsonresume allows to convert it to PDF as well using puppeteer, but it is buggy
# and deprecated by now

RUN sed -i 's#+420 605 066 470#<a class="link-disguise" href="tel:+420605066470" itemprop="phone">+420 605 066 470</a>#g' index.html  && sed -i 's#<a href="https://dostál.eu"#<a class="link-disguise" href="https://dostál.eu"#g' index.html && echo "export PATH=$PATH:$(npm get prefix)/bin" >> ~/.bashrc

###### Create a PDF ######

FROM surnet/alpine-wkhtmltopdf as build-stage-pdf

WORKDIR /app
COPY img.webp .
COPY --from=build-stage /app/index.html .

RUN export XDG_RUNTIME_DIR="/app/" && wkhtmltopdf index.html cv.pdf --enable-local-file-access; exit 0

###### Serve resume html & PDF ######

FROM nginx
LABEL name=resume

COPY ./nginx.conf /etc/nginx/nginx.conf

WORKDIR /app/static
COPY --from=build-stage /app/index.html .
COPY --from=build-stage /app/img.webp .
COPY --from=build-stage-pdf /app/cv.pdf .
CMD ["nginx", "-g", "daemon off;"]
