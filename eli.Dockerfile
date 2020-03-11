FROM livepeerci/build:latest-linux as builder

WORKDIR /build
COPY . .
RUN make livepeer livepeer_cli

FROM nvidia/cuda:10.1-base

ENTRYPOINT ["/usr/bin/livepeer"]

# this is needed to access GPU inside Docker Swarm
ENV NVIDIA_DRIVER_CAPABILITIES=all

COPY --from=builder /build/livepeer /usr/bin/livepeer
COPY --from=builder /build/livepeer_cli /usr/bin/livepeer_cli
