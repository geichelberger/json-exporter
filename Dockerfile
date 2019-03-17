FROM golang as builder
LABEL stage=tempbuilder

WORKDIR /workspace

COPY . .

RUN go get -d ./... && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags="-s -w" -o /json_exporter && \
    useradd -u 10001 scratchuser && \
    mkdir -p /from/etc/ssl/certs && \
    cp /json_exporter /from/json_exporter && \
    cp /etc/ssl/certs/ca-certificates.crt /from/etc/ssl/certs/ca-certificates.crt && \
    cp /etc/passwd /from/etc/passwd

FROM scratch

# COPY --from=builder /json_exporter /json_exporter
# COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
# COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /from/ /

CMD [ "/json_exporter" ]
USER scratchuser