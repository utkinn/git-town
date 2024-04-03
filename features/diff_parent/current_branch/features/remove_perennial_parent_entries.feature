Feature: remove parent entries for perennial branches

  Scenario: parent branch entry for a perennial branch exists
    Given the current branch is a local feature branch "feature-1"
    And the local feature branch "feature-2"
    And the configuration file:
      """
      [branches]
      main = "main"
      perennials = [ "feature-2" ]
      """
    When I run "git town diff-parent"
    Then it prints:
      """
      Removed parent entry for perennial branch "feature-2"
      """
    And this lineage exists now
      | BRANCH    | PARENT |
      | feature-1 | main   |
