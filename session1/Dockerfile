FROM alpine:3.9.6
RUN apk update && apk add bash
ENV ENV_VAR_SECRET=value
ENV ENV_VAR=value
EXPOSE 80
CMD ["/bin/bash", "-c", "echo sleeping; sleep 100000"]
