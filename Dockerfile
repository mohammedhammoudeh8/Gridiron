FROM nginx:alpine

# The commit SHA is passed in by GitHub Actions so every image shows what it was built from.
ARG COMMIT_SHA=local

COPY site/ /usr/share/nginx/html/

RUN SHORT=$(echo "$COMMIT_SHA" | cut -c1-7) \
 && sed -i "s/__COMMIT__/${SHORT}/g" /usr/share/nginx/html/index.html \
 && echo "$COMMIT_SHA" > /usr/share/nginx/html/version.txt

EXPOSE 80
