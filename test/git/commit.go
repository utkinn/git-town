package git

import (
	"log"

	"github.com/git-town/git-town/v11/src/domain"
)

// Commit describes a Git commit.
type Commit struct {
	Author      string `exhaustruct:"optional"`
	Branch      domain.LocalBranchName
	FileContent string   `exhaustruct:"optional"`
	FileName    string   `exhaustruct:"optional"`
	Locations   []string `exhaustruct:"optional"`
	Message     string
	SHA         domain.SHA `exhaustruct:"optional"`
}

// Set assigns the given value to the property with the given Gherkin table name.
func (self *Commit) Set(name, value string) {
	switch name {
	case "BRANCH":
		self.Branch = domain.NewLocalBranchName(value)
	case "LOCATION":
		self.Locations = []string{value}
	case "MESSAGE":
		self.Message = value
	case "FILE NAME":
		self.FileName = value
	case "FILE CONTENT":
		self.FileContent = value
	case "AUTHOR":
		self.Author = value
	default:
		log.Fatalf("unknown Commit property: %s", name)
	}
}
