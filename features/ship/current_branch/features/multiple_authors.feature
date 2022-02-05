@skipWindows
Feature: ship a coworker's feature branch

  Background:
    Given my repo has a feature branch "feature"
    And my repo contains the commits
      | BRANCH  | LOCATION | MESSAGE            | AUTHOR                            |
      | feature | local    | developer commit 1 | developer <developer@example.com> |
      |         |          | developer commit 2 | developer <developer@example.com> |
      |         |          | coworker commit    | coworker <coworker@example.com>   |
    And I am on the "feature" branch

  Scenario: choose myself as the author
    When I run "git-town ship -m 'feature done'" and answer the prompts:
      | PROMPT                                        | ANSWER  |
      | Please choose an author for the squash commit | [ENTER] |
    And my repo now has the commits
      | BRANCH | LOCATION      | MESSAGE      | AUTHOR                            |
      | main   | local, remote | feature done | developer <developer@example.com> |
    And Git Town now has no branch hierarchy information

  Scenario: choose a coworker as the author
    When I run "git-town ship -m 'feature done'" and answer the prompts:
      | PROMPT                                        | ANSWER        |
      | Please choose an author for the squash commit | [DOWN][ENTER] |
    And my repo now has the commits
      | BRANCH | LOCATION      | MESSAGE      | AUTHOR                          |
      | main   | local, remote | feature done | coworker <coworker@example.com> |
    And Git Town now has no branch hierarchy information

  Scenario:  undo
    Given I ran "git-town ship -m 'feature done'" and answered the prompts:
      | PROMPT                                        | ANSWER  |
      | Please choose an author for the squash commit | [ENTER] |
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                        |
      | main    | git branch feature {{ sha 'coworker commit' }} |
      |         | git push -u origin feature                     |
      |         | git revert {{ sha 'feature done' }}            |
      |         | git push                                       |
      |         | git checkout feature                           |
      | feature | git checkout main                              |
      | main    | git checkout feature                           |
    And I am now on the "feature" branch
    And my repo now has the commits
      | BRANCH  | LOCATION      | MESSAGE               |
      | main    | local, remote | feature done          |
      |         |               | Revert "feature done" |
      | feature | local, remote | developer commit 1    |
      |         |               | developer commit 2    |
      |         |               | coworker commit       |
    And my repo now has its initial branches and branch hierarchy
