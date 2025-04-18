# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands
- Build: `swift build`
- Run tests: `swift test`
- Run single test: `swift test --filter VDFlowTests.VDFlowTestsCase/testMethodName`

## Code Style Guidelines
- **Imports**: Simple imports at top, Foundation first, followed by SwiftUI
- **Formatting**: 4-space indentation, braces on same line as declaration
- **Types**: PascalCase for types, heavy use of generics and protocol-oriented design
- **Naming**: camelCase for variables/functions, descriptive naming
- **Error Handling**: Custom error types with descriptive messages
- **Macros**: Used for generating boilerplate code with @Steps annotation
- **Architecture**: Follows an observer pattern with StepSystem for state management

## Project Overview
VDFlow provides a declarative way to define application navigation flows as a tree structure. The codebase uses Swift Package Manager and is focused on SwiftUI integration through property wrappers like @StateStep that bind navigation state to UI components.