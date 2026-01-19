package handlers

import (
	"net/http"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type UserHandler struct {
	db *gorm.DB
}

func NewUserHandler(db *gorm.DB) *UserHandler {
	return &UserHandler{db: db}
}

// ListOwners returns all users with role='owner' including their syndicate shares
func (h *UserHandler) ListOwners(c *gin.Context) {
	var users []models.User

	// Query users with role='owner', preload their syndicate shares and yachts
	if err := h.db.
		Preload("SyndicateShares").
		Preload("SyndicateShares.Yacht").
		Where("role = ?", models.RoleOwner).
		Order("first_name ASC, last_name ASC").
		Find(&users).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch owners"})
		return
	}

	c.JSON(http.StatusOK, users)
}

// GetOwner returns a single owner by ID with their syndicate shares
func (h *UserHandler) GetOwner(c *gin.Context) {
	id := c.Param("id")

	var user models.User
	if err := h.db.
		Preload("SyndicateShares").
		Preload("SyndicateShares.Yacht").
		Where("id = ? AND role = ?", id, models.RoleOwner).
		First(&user).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{"error": "Owner not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch owner"})
		return
	}

	c.JSON(http.StatusOK, user)
}
