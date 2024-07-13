FROM golang:1.19 as builder
WORKDIR /app
COPY . .
RUN go mod tidy
RUN go build -o app .

FROM gcr.io/distroless/base
WORKDIR /root/
COPY --from=builder /app/app .
CMD ["./app"]
