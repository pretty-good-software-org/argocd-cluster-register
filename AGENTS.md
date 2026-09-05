---
last_validated: 2026-09-05T15:10:22Z
project_type: go-kubebuilder-controller
---

# Agent Instructions: argocd-cluster-register

This file provides guidance to coding agents working in this repository.

## Repository Overview

An ArgoCD controller, built with Go and Kubebuilder, that watches Cluster API (CAPI) `Cluster` resources and registers
them with ArgoCD: it creates the deterministic cluster Secret in the `argocd` namespace, adds the cluster to the
configured ArgoCD `AppProject`s, and installs CNI (Cilium) via a `ClusterResourceSet` once the control plane is ready.
The controller never talks to CAPI or ArgoCD directly outside the Kubernetes API, so it reuses Kubernetes RBAC.

## Repository Structure

```text
.
├── .changes
│   ├── header.tpl.md
│   ├── unreleased
│   │   └── .gitkeep
│   └── v0.0.27.md
├── .changie.yaml
├── .dockerignore
├── .github
│   ├── dependabot.yml
│   └── workflows
│       ├── build.yaml
│       ├── image.yaml
│       ├── lint.yml
│       ├── publish.yaml
│       └── scan.yaml
├── .gitignore
├── .golangci.yml
├── .mise.ci.toml
├── .mise.development.toml
├── .mise.toml
├── .miserc.toml
├── .rumdl.toml
├── AGENTS.md
├── CHANGELOG.md
├── CLAUDE.md
├── Dockerfile
├── GEMINI.md
├── LICENSE
├── Makefile
├── PROJECT
├── README.md
├── cni
│   └── cilium
│       ├── cilium.go
│       └── cilium.yaml
├── conf
│   ├── conf.go
│   └── conf_test.go
├── config
│   ├── default
│   │   ├── kustomization.yaml
│   │   ├── manager_auth_proxy_patch.yaml
│   │   └── manager_config_patch.yaml
│   ├── manager
│   │   ├── controller_manager_config.yaml
│   │   ├── kustomization.yaml
│   │   └── manager.yaml
│   ├── prometheus
│   │   ├── kustomization.yaml
│   │   └── monitor.yaml
│   ├── rbac
│   │   ├── auth_proxy_client_clusterrole.yaml
│   │   ├── auth_proxy_role.yaml
│   │   ├── auth_proxy_role_binding.yaml
│   │   ├── auth_proxy_service.yaml
│   │   ├── generator_editor_role.yaml
│   │   ├── generator_viewer_role.yaml
│   │   ├── kustomization.yaml
│   │   ├── leader_election_role.yaml
│   │   ├── leader_election_role_binding.yaml
│   │   ├── role.yaml
│   │   ├── role_binding.yaml
│   │   └── service_account.yaml
│   └── samples
│       └── registry_v1alpha1_generator.yaml
├── controllers
│   ├── cluster_controller.go
│   └── suite_test.go
├── go.mod
├── go.sum
├── hack
│   └── boilerplate.go.txt
├── lefthook
│   └── lint.yml
├── lefthook.yml
├── main
│   └── main.go
├── mise-tasks
│   ├── check
│   │   └── markdown-format
│   ├── format
│   │   └── markdown
│   ├── lint
│   │   ├── default
│   │   └── rumdl
│   ├── setup
│   │   └── default
│   └── test
│       └── staged-markdown-hook
├── mise.development.lock
├── mise.lock
├── scripts
│   ├── check-staged-markdown-test.sh
│   ├── check-staged-markdown.sh
│   └── rumdl-markdown-boundary-test.sh
└── version.go
```

## Development Guidelines

### Code Style

- Controller logic lives in `controllers/cluster_controller.go`; configuration parsing lives in `conf/conf.go`
  (`ROLE_ARN` for EKS clusters, `PROJECT` for the comma-separated ArgoCD project list).
- CNI (Cilium) manifest generation lives in `cni/cilium/`.
- Logging uses `go.uber.org/zap`.
- Run `make fmt` and `make vet` before committing; `make lint` runs `golangci-lint` (config in `.golangci.yml`).

## Build, test, and lint

```bash
make build            # go fmt, go vet, then build the manager binary into bin/
make run              # run the controller locally against ~/.kube/config
make test             # generate, fmt, vet, then run unit tests (ginkgo/gomega) via envtest
make lint             # golangci-lint
make manifests        # regenerate CRD manifests and RBAC YAMLs via controller-gen
make generate         # regenerate DeepCopy boilerplate via controller-gen
mise run lint:default # markdown lint (check:markdown-format + lint:rumdl)
```

`mise run setup:default` installs pinned tools and `lefthook` git hooks (`.mise.toml`, `.mise.development.toml`).
CI runs lint (`.github/workflows/lint.yml`), build (`build.yaml`), image build/publish (`image.yaml`, `publish.yaml`),
and security scanning (`scan.yaml`).

## Git Workflow

```bash
# Check status first
git status

# Create feature branch
git checkout -b feat/description

# Make changes, then commit
git add .
git commit -m "type: description"

# Push and create PR
git push -u origin HEAD
```
