# Software Development Tycoon

Software Development Tycoon is a single-player simulation game that teaches software project management through hands-on decision-making. Players manage software projects by balancing scope, cost, schedule, quality, risks, and stakeholder satisfaction across the software development lifecycle (SDLC).

## Overview

Many software projects fail because of poor planning, weak management, resource issues, and ineffective SDLC decisions. This game helps students and early-career professionals gain practical project management experience in a low-risk environment.

Players will:

* Manage one software project at a time
* Make sprint-based decisions
* Choose between methodologies such as Agile, Waterfall, V-Model, and Spiral
* Allocate resources and manage risks
* Track project outcomes through cost, schedule, quality, and stakeholder satisfaction metrics

## Learning Objectives

* Understand the phases of the SDLC and how they connect
* Evaluate trade-offs between scope, time, cost, and quality
* See how early decisions affect later project outcomes
* Compare different software development methodologies

## Core Features

* Single-player simulation gameplay
* Sprint-based planning and management
* Methodology selection (Agile, Waterfall, V-Model, Spiral)
* Risk and resource management systems
* Performance scoring based on key project metrics
* Simplified but realistic project management scenarios

## Team Roles

* William — Project Lead, Tech Lead, Frontend Developer
* Joris — Project Manager, DevOps, UX Designer
* Priyanka — Test Engineer, Requirements Engineer
* Zhuo — UX Designer
* Krish — Requirements Engineer

## Key Risks

* Scope creep from too many SDLC features
* Overly complex simulation systems
* Poor balance between methodologies
* Limited playtesting time
* UI complexity overwhelming players
* Team skill gaps across design and development
* Late deployment or hosting issues
* Educational goals not being met
* Repetitive or unfair event systems

## Assumptions

* The game will remain single-player
* SDLC concepts will be simplified for learning purposes
* One polished gameplay loop is prioritized over many features
* Development methodologies affect gameplay behavior, not architecture
* A lightweight backend is sufficient
* Launch content will be limited but replayable
* Players are motivated learners
* Team availability remains consistent

## More Information

This README provides a high-level overview of the project.

For detailed documentation on gameplay systems, SDLC mechanics, project risks, assumptions, methodology behavior, and team responsibilities, please visit the GitHub Wiki.

## Release Process

This repository uses lightweight GitHub Actions automation for validation and releases.

* Pull requests targeting `main` and direct pushes to `main` run lightweight validation only.
* Versioned releases are created by pushing a git tag that matches `vMAJOR.MINOR` or `vMAJOR.MINOR.PATCH`, such as `v1.0` or `v1.0.1`.
* Release tags trigger a GitHub Actions workflow that builds and uploads a macOS `.dmg` and a Windows `.zip` containing the exported `.exe` and `.pck`.

Example release flow:

```bash
git tag v1.0
git push origin v1.0
```
