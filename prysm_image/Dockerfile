FROM cockroachdb/bazel:20221122-164914 AS builder

RUN git clone https://github.com/prysmaticlabs/prysm.git && \
    cd prysm && \
    git checkout capella && \
    bazel build //cmd/prysmctl

FROM ubuntu:22.04
RUN apt-get update && apt-get -y upgrade
COPY --from=builder /prysm/bazel-bin/cmd/prysmctl/prysmctl_/prysmctl /usr/local/bin/prysmctl

RUN addgroup --gid 1000 mark
RUN useradd -m -g 1000 -s /bin/bash -u 1000 mark

USER 1000
WORKDIR /home/mark

