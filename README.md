# ArkeonProject — CI/CD Architecture

This repository contains the official CI/CD architecture used across the entire organization.

## Folder structure

ci-templates/ → Reusable base workflows
scripts/ → Automation utilities (install CI, configure secrets)


## Installing CI/CD in a project

Inside a repository:



gh repo clone ArkeonProject/organization-tools
cd organization-tools/scripts
./setup-ci.sh


## Configure Vercel secrets



./scripts/setup-vercel-secrets.sh ArkeonProject/repo <projectId> <orgId>


## Workflows included

- Universal CI for develop  
- CD for Node + Vercel  
- CD for Python + Docker  
- Release Please automated release handling  

