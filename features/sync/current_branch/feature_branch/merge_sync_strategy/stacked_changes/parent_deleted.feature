Feature: syncing a branch whose parent was shipped

  Background:
    Given a feature branch "parent"
    And a feature branch "child" as a child of "parent"
    And the commits
      | BRANCH | LOCATION      | MESSAGE       |
      | parent | local, origin | parent commit |
      | child  | local, origin | child commit  |
    And origin ships the "parent" branch
    And the current branch is "child"
    When I run "git-town sync"

  Scenario: result
    Then it runs the commands
      | BRANCH | COMMAND                          |
      | child  | git fetch --prune --tags         |
      |        | git checkout main                |
      | main   | git rebase origin/main           |
      |        | git checkout parent              |
      | parent | git merge --no-edit main         |
      |        | git checkout main                |
      | main   | git branch -D parent             |
      |        | git checkout child               |
      | child  | git merge --no-edit origin/child |
      |        | git merge --no-edit main         |
      |        | git push                         |
    And it prints:
      """
      deleted branch "parent"
      """
    And the current branch is still "child"
    And the branches are now
      | REPOSITORY    | BRANCHES    |
      | local, origin | main, child |
    And this lineage exists now
      | BRANCH | PARENT |
      | child  | main   |

  Scenario: undo
    When I run "git-town undo"
    Then it runs the commands
      | BRANCH | COMMAND                                         |
      | child  | git reset --hard {{ sha 'child commit' }}       |
      |        | git push --force-with-lease --force-if-includes |
      |        | git checkout main                               |
      | main   | git reset --hard {{ sha 'initial commit' }}     |
      |        | git branch parent {{ sha 'parent commit' }}     |
      |        | git checkout child                              |
    And the current branch is still "child"
    And the initial branches and lineage exist
