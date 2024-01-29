#### BASE ####
FROM golang:1.21 as builder

RUN apt-get update && apt-get install -y \
 clang \
 gcc-multilib \
 libbpf-dev

RUN go install github.com/cilium/ebpf/cmd/bpf2go@master

WORKDIR /src
COPY . .
RUN go generate ./...
RUN go build ./...

#### USERSPACE ####
FROM registry.fedoraproject.org/fedora-minimal:latest as userspace

COPY --from=builder /src/bpfman-fosdem24 .
COPY --from=builder /src/bpf_bpfel.o .

ENTRYPOINT ["./bpfman-fosdem24"]

#### KERNEL/BPF ####
FROM scratch as bpf

COPY --from=builder /src/bpf_bpfel.o bpf_bpfel.o
LABEL io.ebpf.program_type xdp
LABEL io.ebpf.filename bpf_bpfel.o
LABEL io.ebpf.program_name bpfman-fosdem24
LABEL io.ebpf.bpf_function_name xdp_stats
