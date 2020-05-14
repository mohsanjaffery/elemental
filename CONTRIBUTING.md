# Contributing Guidelines

Thank you for your interest in contributing to the project.

## Contributing via Pull Requests
Contributions via pull requests are much appreciated. Before sending a pull request, please ensure that:

1. You are working against the latest source on the **master** branch.
1. You check existing open, and recently merged, pull requests to make sure someone else hasn't addressed the problem already.
1. You have `pre-commit` installed. [See Install pre-commit](#install-pre-commit)

To send a pull request, please:

1. Clone the repository.
2. Modify the source; please focus on the specific change you are contributing. If you also reformat all the code, it will be hard for us to focus on your change.
3. Ensure local tests pass.
4. Commit to your branch using clear commit messages.
5. Send a pull request, answering any default questions in the pull request interface.
6. Pay attention to any automated CI failures reported in the pull request, and stay involved in the conversation.

## Install pre-commit

Git hook scripts are useful for identifying simple issues before submission to code review. We run our hooks on every commit to automatically point out issues in code to allow a code reviewer to focus on the architecture of a change while not wasting time with trivial style nitpicks.

### 1. Installation
1. Using pip:

   `pip install pre-commit`

1. Using homebrew:

   `brew install pre-commit`

### 2. Install the git hook scripts

run pre-commit install to set up the git hook scripts

```
$ pre-commit install
pre-commit installed at .git/hooks/pre-commit
```

### 3. Run against all the files

it's usually a good idea to run the hooks against all of the files before doing `git commit`

`$ pre-commit run --all-files`
