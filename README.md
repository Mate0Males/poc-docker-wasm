# POC Docker + WebAssembly

## Questions

### Docker

**What is it?**
Docker is a platform that packages an application together with all its dependencies into a **container**, so it runs the same way on any computer or server. Unlike a virtual machine, a container shares the host operating system kernel, which makes it lighter and lets it start in seconds.

**How does it work?**
1. A `Dockerfile` is written with the instructions to build the environment.
2. `docker build` turns it into an **image**, a read-only template made of layers.
3. `docker run` creates a **container**, which is a running instance of that image.

Under the hood, Docker uses Linux kernel features: *namespaces* to isolate processes, files, and network, and *cgroups* to limit CPU and memory.

**Where can it be used?**
- Development with identical environments across the whole team.
- Automated testing and CI/CD pipelines.
- Microservice architectures.
- Cloud deployment (AWS, Google Cloud, Azure) and orchestration with Kubernetes.

**Who implements it?**
Docker Inc. maintains Docker Engine and Docker Desktop. Alternatives such as Podman exist, and cloud providers (AWS ECS, Google Cloud Run, Azure Container Apps) and Kubernetes run containers at large scale.

**Who created it?**
Solomon Hykes and his team at dotCloud, publicly presented in March 2013 at the PyCon conference.

### WebAssembly (Wasm)

**What is it?**
WebAssembly is a low-level, portable, and safe binary format designed to run at near-native speed inside the browser. Languages such as C, C++, Rust, or Go can be compiled to Wasm. It has been a W3C standard since 2019.

**How does it work?**
1. Code is written in a source language (or in the text format `.wat`).
2. A compiler (Emscripten, `rustc`, `wat2wasm`) generates a binary `.wasm` file.
3. The browser validates, compiles, and runs that file inside an isolated virtual machine (sandbox).
4. JavaScript communicates with the module through its **exports** (functions it exposes) and **imports** (functions it receives).

**Where can it be used?**
- Heavy games and applications in the browser (Figma, Google Earth, AutoCAD Web).
- Client-side image, video, or audio processing.
- Edge computing and serverless functions (Cloudflare Workers, Fastly).
- Plugins for proxies and systems such as Envoy.

**Who implements it?**
Browsers: Chrome (V8), Firefox (SpiderMonkey), Safari (JavaScriptCore), and Edge. Outside the browser, runtimes such as Wasmtime, Wasmer, and WasmEdge exist, and the Bytecode Alliance drives the WASI standard.

**Who created it?**
It emerged from a collaboration between Mozilla, Google, Microsoft, and Apple, announced in 2015. It built on earlier projects such as asm.js (Mozilla) and PNaCl (Google).

---

## Proof of Concept (POC)

### Idea
A WebAssembly module that adds two numbers, compiled inside a Docker container and served on a web page.

### How it works
1. **Docker multi-stage build:**
   - **Stage 1 (`compilador`):** uses Ubuntu 22.04, installs `wabt`, and converts `suma.wat` (text format) into `suma.wasm` (binary format) with `wat2wasm`.
   - **Stage 2 (final image):** uses `nginx:alpine` and copies `index.html` and the generated `suma.wasm` into the web server directory. The compiler stage is discarded, so the final image stays small.
2. **Wasm module (`suma.wat`):** exports a function `suma(a, b)` that returns `a + b` using 32-bit integers.
3. **Web page (`index.html`):** downloads `suma.wasm`, instantiates it with `WebAssembly.instantiate`, calls `suma(5, 7)`, and shows the result on screen.
4. **Container execution:** `docker run` starts nginx on port 80 inside the container, mapped to port 8080 on the host.

### Result
Opening `http://localhost:8080` shows **12**, the result of the sum computed by the WebAssembly module.

### Files
- `Dockerfile`: multi-stage build definition.
- `suma.wat`: WebAssembly module in text format.
- `index.html`: page that loads and runs the module.
- `README.md`: this documentation.

### Run
```bash
docker build -t poc-wasm .
docker run -d -p 8080:80 --name poc-wasm poc-wasm
```

Open `http://localhost:8080` in the browser. It should display **12**.

To stop and clean up:
```bash
docker stop poc-wasm && docker rm poc-wasm
```