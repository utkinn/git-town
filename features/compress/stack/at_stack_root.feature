Feature: compress the commits on an entire stack when at the stack root

  Background:
    Given feature branch "alpha" with these commits
      | MESSAGE | FILE NAME | FILE CONTENT |
      | alpha 1 | alpha_1   | alpha 1      |
      | alpha 2 | alpha_2   | alpha 2      |
      | alpha 3 | alpha_3   | alpha 3      |
    And feature branch "beta" with these commits is a child of "alpha"
      | MESSAGE | FILE NAME | FILE CONTENT |
      | beta 1  | beta_1    | beta 1       |
      | beta 2  | beta_2    | beta 2       |
      | beta 3  | beta_3    | beta 3       |
    And feature branch "gamma" with these commits is a child of "beta"
      | MESSAGE | FILE NAME | FILE CONTENT |
      | gamma 1 | gamma_1   | gamma 1      |
      | gamma 2 | gamma_2   | gamma 2      |
      | gamma 3 | gamma_3   | gamma 3      |
    And the current branch is "alpha"
    And an uncommitted file
    When I run "git-town compress --stack"

  @debug @this
  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                                         |
      | alpha  | git fetch --prune --tags                        |
      |        | git add -A                                      |
      |        | git stash                                       |
      |        | git reset --soft main                           |
      |        | git commit -m "alpha 1"                         |
      |        | git push --force-with-lease --force-if-includes |
      |        | git checkout beta                               |
      | beta   | git reset --soft alpha                          |
      |        | git commit -m "beta 1"                          |
      |        | git push --force-with-lease --force-if-includes |
      |        | git checkout gamma                              |
      | gamma  | git reset --soft beta                           |
      |        | git commit -m "gamma 1"                         |
      |        | git push --force-with-lease --force-if-includes |
      |        | git checkout alpha                              |
      | alpha  | git stash pop                                   |
    And all branches are now synchronized
    And the current branch is still "alpha"
    And these commits exist now
      | BRANCH | LOCATION      | MESSAGE |
      | alpha  | local, origin | alpha 1 |
      | beta   | local, origin | alpha 1 |
      |        |               | beta 1  |
      | gamma  | local, origin | alpha 1 |
      |        |               | beta 1  |
      |        |               | gamma 1 |
    And file "alpha_1" still has content "alpha 1"
    And file "alpha_2" still has content "alpha 2"
    And file "alpha_3" still has content "alpha 3"
    And file "beta_1" still has content "beta 1"
    And file "beta_2" still has content "beta 2"
    And file "beta_3" still has content "beta 3"
    And file "gamma_1" still has content "gamma 1"
    And file "gamma_2" still has content "gamma 2"
    And file "gamma_3" still has content "gamma 3"
    And the uncommitted file still exists

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH  | COMMAND                                         |
      | feature | git add -A                                      |
      |         | git stash                                       |
      |         | git reset --hard {{ sha 'commit 3' }}           |
      |         | git push --force-with-lease --force-if-includes |
      |         | git stash pop                                   |
    And the current branch is still "feature"
    And the initial commits exist
    And the initial branches and lineage exist
    And the uncommitted file still exists
