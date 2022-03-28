If you're familar with docker a first naive approach to inspect the docker layers could be:

```bash
sudo docker history ghcr.io/benjitrapp/damn-vulnerable-docker-container:main
IMAGE          CREATED       CREATED BY                                      SIZE      COMMENT
cc0d35b829f0   6 days ago    CMD ["/app/dockerentry.sh"]                     0B        buildkit.dockerfile.v0
<missing>      6 days ago    WORKDIR /opt/kubernetes                         0B        buildkit.dockerfile.v0
<missing>      6 days ago    ENV KUBECONFIG=/opt/kubernetes                  0B        buildkit.dockerfile.v0
<missing>      6 days ago    RUN /bin/sh -c curl -kLO "https://dl.k8s.io/…   46.6MB    buildkit.dockerfile.v0
<missing>      6 days ago    RUN /bin/sh -c apk add wireguard-tools curl …   11.9MB    buildkit.dockerfile.v0
<missing>      6 days ago    USER 0                                          0B        buildkit.dockerfile.v0
<missing>      6 days ago    COPY containerfiles / # buildkit                11.4kB    buildkit.dockerfile.v0
<missing>      6 days ago    ENV AWS_SECRET_ACCESS_KEY=mk30783jZKr8zVp8M6…   0B        buildkit.dockerfile.v0
<missing>      6 days ago    ENV AWS_ACCESS_KEY=AKIAYVP4CIPPOWONZTGT         0B        buildkit.dockerfile.v0
<missing>      11 days ago   /bin/sh -c #(nop)  CMD ["/bin/sh"]              0B        
<missing>      11 days ago   /bin/sh -c #(nop) ADD file:cf4b631a115c2bbfb…   5.57MB    
```

This command will reveal the Secrets hidden in the environment variables - but be shorten so that we can't just copy and paste it. Tweaking the command will lead to this result:

```bash
sudo docker history ghcr.io/benjitrapp/damn-vulnerable-docker-container:main --no-trunc --human                
IMAGE                                                                     CREATED       CREATED BY                                                                                                                                   SIZE      COMMENT
sha256:cc0d35b829f0a8596a9c6015f38a6f5d396186f546fe86a06160b841640bef0a   6 days ago    CMD ["/app/dockerentry.sh"]                                                                                                                  0B        buildkit.dockerfile.v0
<missing>                                                                 6 days ago    WORKDIR /opt/kubernetes                                                                                                                      0B        buildkit.dockerfile.v0
<missing>                                                                 6 days ago    ENV KUBECONFIG=/opt/kubernetes                                                                                                               0B        buildkit.dockerfile.v0
<missing>                                                                 6 days ago    RUN /bin/sh -c curl -kLO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" # buildkit   46.6MB    buildkit.dockerfile.v0
<missing>                                                                 6 days ago    RUN /bin/sh -c apk add wireguard-tools curl wireguard-tools-wg &&     bash /app/docker-install.sh # buildkit                                 11.9MB    buildkit.dockerfile.v0
<missing>                                                                 6 days ago    USER 0                                                                                                                                       0B        buildkit.dockerfile.v0
<missing>                                                                 6 days ago    COPY containerfiles / # buildkit                                                                                                             11.4kB    buildkit.dockerfile.v0
<missing>                                                                 6 days ago    ENV AWS_SECRET_ACCESS_KEY=mk30783jZKr8zVp8M6HtYG9rs85r8XTVo2FkfHe0                                                                           0B        buildkit.dockerfile.v0
<missing>                                                                 6 days ago    ENV AWS_ACCESS_KEY=AKIAYVP4CIPPOWONZTGT                                                                                                      0B        buildkit.dockerfile.v0
<missing>                                                                 11 days ago   /bin/sh -c #(nop)  CMD ["/bin/sh"]                                                                                                           0B        
<missing>                                                                 11 days ago   /bin/sh -c #(nop) ADD file:cf4b631a115c2bbfbd81cad2d3041bceb64a8136aac92ba8a63b6c51d60af764 in /                                             5.57MB    
```


Let's check some more advanced tools:
Running `$skopeo inspect --config docker://ghcr.io/benjitrapp/damn-vulnerable-docker-container:main` will lead to this json output: 

```json
{
    "created": "2022-03-22T08:03:57.441674332Z",
    "architecture": "amd64",
    "os": "linux",
    "config": {
        "User": "0",
        "Env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
            "AWS_ACCESS_KEY=AKIAYVP4CIPPOWONZTGT",
            "AWS_SECRET_ACCESS_KEY=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",
            "KUBECONFIG=/opt/kubernetes"
        ],
        "Cmd": [
            "/app/dockerentry.sh"
        ],
        "WorkingDir": "/opt/kubernetes",
        "Labels": {
            "org.opencontainers.image.created": "2022-03-22T08:03:51.089Z",
            "org.opencontainers.image.description": "",
            "org.opencontainers.image.licenses": "",
            "org.opencontainers.image.revision": "b7974b534f395e64824696037e4f4037b6258cc5",
            "org.opencontainers.image.source": "https://github.com/BenjiTrapp/damn-vulnerable-docker-container",
            "org.opencontainers.image.title": "damn-vulnerable-docker-container",
            "org.opencontainers.image.url": "https://github.com/BenjiTrapp/damn-vulnerable-docker-container",
            "org.opencontainers.image.version": "main"
        }
    },
    "rootfs": {
        "type": "layers",
        "diff_ids": [
            "sha256:5e03d8cae8773cb694fff1d55da34a40d23c2349087ed15ce68476395d33753c",
            "sha256:0ae9d5a027697bd182c8c9bb9f0adf6f9f8befb3822a404f863d1e6d9aed4acd",
            "sha256:4b2ef7698a83807a593286de43bf7cbe7363b89a51daddc9b2ab569ef276eb5d",
            "sha256:7c892a87ecdd7d690bc8dba1452e182def6fcc75d53e46e5c39b356716734fb9",
            "sha256:5f70bf18a086007016e948b04aed3b82103a36bea41755b6cddfaf10ace3c6ef"
        ]
    },
    "history": [
        {
            "created": "2022-03-17T04:01:58.883733237Z",
            "created_by": "/bin/sh -c #(nop) ADD file:cf4b631a115c2bbfbd81cad2d3041bceb64a8136aac92ba8a63b6c51d60af764 in / "
        },
        {
            "created": "2022-03-17T04:01:59.188838147Z",
            "created_by": "/bin/sh -c #(nop)  CMD [\"/bin/sh\"]",
            "empty_layer": true
        },
        {
            "created": "2022-03-22T08:03:53.65860474Z",
            "created_by": "ENV AWS_ACCESS_KEY=AKIAYVP4CIPPOWONZTGT",
            "comment": "buildkit.dockerfile.v0",
            "empty_layer": true
        },
        {
            "created": "2022-03-22T08:03:53.65860474Z",
            "created_by": "ENV AWS_SECRET_ACCESS_KEY=mk30783jZKr8zVp8M6HtYG9rs85r8XTVo2FkfHe0",
            "comment": "buildkit.dockerfile.v0",
            "empty_layer": true
        },
        {
            "created": "2022-03-22T08:03:53.65860474Z",
            "created_by": "COPY containerfiles / # buildkit",
            "comment": "buildkit.dockerfile.v0"
        },
        {
            "created": "2022-03-22T08:03:53.65860474Z",
            "created_by": "USER 0",
            "comment": "buildkit.dockerfile.v0",
            "empty_layer": true
        },
        {
            "created": "2022-03-22T08:03:55.011627196Z",
            "created_by": "RUN /bin/sh -c apk add wireguard-tools curl wireguard-tools-wg \u0026\u0026     bash /app/docker-install.sh # buildkit",
            "comment": "buildkit.dockerfile.v0"
        },
        {
            "created": "2022-03-22T08:03:57.311226418Z",
            "created_by": "RUN /bin/sh -c curl -kLO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\" # buildkit",
            "comment": "buildkit.dockerfile.v0"
        },
        {
            "created": "2022-03-22T08:03:57.311226418Z",
            "created_by": "ENV KUBECONFIG=/opt/kubernetes",
            "comment": "buildkit.dockerfile.v0",
            "empty_layer": true
        },
        {
            "created": "2022-03-22T08:03:57.441674332Z",
            "created_by": "WORKDIR /opt/kubernetes",
            "comment": "buildkit.dockerfile.v0"
        },
        {
            "created": "2022-03-22T08:03:57.441674332Z",
            "created_by": "CMD [\"/app/dockerentry.sh\"]",
            "comment": "buildkit.dockerfile.v0",
            "empty_layer": true
        }
    ]
}

```
