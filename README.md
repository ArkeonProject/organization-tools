# ArkeonProject — CI/CD Architecture

This repository contains the official reusable CI/CD system for all ArkeonProject repositories.

## Structure

ci-templates/  
scripts/  

## Install CI/CD into a repository

gh repo clone ArkeonProject/organization-tools  
cd organization-tools/scripts  
./setup-ci.sh  

## Configure Vercel secrets

./scripts/setup-vercel-secrets.sh ArkeonProject/repo <projectId> <orgId>  
