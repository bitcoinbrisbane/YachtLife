package handlers

import (
	"net/http"

	"github.com/bitcoinbrisbane/yachtlife/internal/models"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// YachtHandler handles yacht requests
type YachtHandler struct {
	db *gorm.DB
}

// NewYachtHandler creates a new yacht handler
func NewYachtHandler(db *gorm.DB) *YachtHandler {
	return &YachtHandler{db: db}
}

// ListYachts returns all yachts
func (h *YachtHandler) ListYachts(c *gin.Context) {
	var yachts []models.Yacht

	if err := h.db.Find(&yachts).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to fetch yachts",
		})
		return
	}

	c.JSON(http.StatusOK, yachts)
}

// GetYacht returns a single yacht by ID
func (h *YachtHandler) GetYacht(c *gin.Context) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid yacht ID",
		})
		return
	}

	var yacht models.Yacht
	if err := h.db.First(&yacht, id).Error; err != nil {
		if err == gorm.ErrRecordNotFound {
			c.JSON(http.StatusNotFound, gin.H{
				"error": "yacht not found",
			})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to fetch yacht",
		})
		return
	}

	c.JSON(http.StatusOK, yacht)
}
