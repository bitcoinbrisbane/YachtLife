package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type UserRole string

const (
	RoleAdmin   UserRole = "admin"
	RoleManager UserRole = "manager"
	RoleOwner   UserRole = "owner"
)

type User struct {
	ID              uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	AppleUserID     string         `gorm:"uniqueIndex;size:255" json:"apple_user_id,omitempty"`
	Email           string         `gorm:"uniqueIndex;not null;size:255" json:"email"`
	PasswordHash    string         `gorm:"size:255" json:"-"` // Only for managers/admins
	FirstName       string         `gorm:"size:255" json:"first_name"`
	LastName        string         `gorm:"size:255" json:"last_name"`
	Phone           string         `gorm:"size:50" json:"phone,omitempty"`
	Country         string         `gorm:"size:100" json:"country,omitempty"`
	Role            UserRole       `gorm:"type:varchar(20);not null;default:'owner'" json:"role"`
	ProfileImageURL string         `gorm:"size:500" json:"profile_image_url,omitempty"`
	LastLoginAt     *time.Time     `json:"last_login_at,omitempty"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`
}

func (User) TableName() string {
	return "users"
}
