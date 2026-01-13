FROM ubuntu:22.04

LABEL maintainer="ghobrial-lab"
LABEL description="Docker image for arcasHLA - HLA typing from RNA-seq"
LABEL version="0.6.0"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    python3 \
    python3-pip \
    wget \
    bedtools \
    samtools \
    pigz \
    && rm -rf /var/lib/apt/lists/*

# Install kallisto (required for arcasHLA reference and genotyping)
RUN wget -q https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz && \
    tar -xzf kallisto_linux-v0.46.1.tar.gz && \
    mv kallisto/kallisto /usr/local/bin/ && \
    rm -rf kallisto kallisto_linux-v0.46.1.tar.gz

# Set working directory
WORKDIR /opt

# Clone arcasHLA repository
RUN git clone https://github.com/RabadanLab/arcasHLA.git && \
    cd arcasHLA && \
    git checkout master

# Install Python dependencies
RUN pip3 install --no-cache-dir \
    biopython \
    numpy \
    pandas \
    scipy

# Set Python path to include arcasHLA
ENV PYTHONPATH="/opt/arcasHLA:${PYTHONPATH}"

# Add arcasHLA to PATH
ENV PATH="/opt/arcasHLA:${PATH}"

# Download and set up arcasHLA reference data
WORKDIR /opt/arcasHLA

# Make arcasHLA executable
RUN chmod +x arcasHLA

# Download HLA reference database
# This downloads the IMGT/HLA database and builds the reference files
RUN ./arcasHLA reference --version 3.24.0

# Verify installation
RUN python3 arcasHLA --help || true

# Set default working directory
WORKDIR /data

# Set default command
CMD ["/bin/bash"]
