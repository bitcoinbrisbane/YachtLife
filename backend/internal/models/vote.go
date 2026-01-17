package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type VoteType string
type VoteStatus string

const (
	VoteTypeYesNo          VoteType = "yes_no"
	VoteTypeMultipleChoice VoteType = "multiple_choice"

	VoteStatusDraft  VoteStatus = "draft"
	VoteStatusActive VoteStatus = "active"
	VoteStatusClosed VoteStatus = "closed"
)

type Vote struct {
	ID          uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	YachtID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"yacht_id"`
	CreatedBy   uuid.UUID      `gorm:"type:uuid;not null" json:"created_by"`
	Title       string         `gorm:"size:255;not null" json:"title"`
	Description string         `gorm:"type:text" json:"description"`
	VoteType    VoteType       `gorm:"type:varchar(20);not null" json:"vote_type"`
	Options     datatypes.JSON `gorm:"type:jsonb" json:"options,omitempty"` // For multiple choice votes
	StartDate   time.Time      `json:"start_date"`
	EndDate     time.Time      `json:"end_date"`
	Status      VoteStatus     `gorm:"type:varchar(20);not null;default:'draft'" json:"status"`
	CreatedAt   time.Time      `json:"created_at"`
	UpdatedAt   time.Time      `json:"updated_at"`

	// Relationships
	Yacht     Yacht `gorm:"foreignKey:YachtID;constraint:OnDelete:CASCADE" json:"yacht,omitempty"`
	CreatedByUser User  `gorm:"foreignKey:CreatedBy" json:"created_by_user,omitempty"`
}

func (Vote) TableName() string {
	return "votes"
}

type VoteResponse struct {
	ID        uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	VoteID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"vote_id"`
	UserID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"user_id"`
	Response  datatypes.JSON `gorm:"type:jsonb;not null" json:"response"` // User's vote response
	VotedAt   time.Time      `json:"voted_at"`
	CreatedAt time.Time      `json:"created_at"`

	// Relationships
	Vote Vote `gorm:"foreignKey:VoteID;constraint:OnDelete:CASCADE" json:"vote,omitempty"`
	User User `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"user,omitempty"`
}

func (VoteResponse) TableName() string {
	return "vote_responses"
}
