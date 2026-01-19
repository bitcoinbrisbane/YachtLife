package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/datatypes"
)

type Yacht struct {
	ID                  uuid.UUID      `gorm:"type:uuid;primary_key;default:gen_random_uuid()" json:"id"`
	Name                string         `gorm:"size:255;not null" json:"name"`
	Manufacturer        string         `gorm:"size:255" json:"manufacturer"`
	Model               string         `gorm:"size:255" json:"model"`
	Year                int            `json:"year"`
	LengthFeet          float64        `gorm:"type:decimal(10,2)" json:"length_feet"`
	BeamFeet            float64        `gorm:"type:decimal(10,2)" json:"beam_feet"`
	DraftFeet           float64        `gorm:"type:decimal(10,2)" json:"draft_feet"`
	HullID              string         `gorm:"uniqueIndex;size:255" json:"hull_id"` // Hull Identification Number
	Registration        string         `gorm:"size:255" json:"registration"`
	RegistrationCountry string         `gorm:"size:100" json:"registration_country"`
	HomePort            string         `gorm:"size:255" json:"home_port"`
	BerthLocation       string         `gorm:"size:255" json:"berth_location"`        // Marina/berth name
	BerthBayNumber      string         `gorm:"size:50" json:"berth_bay_number"`       // Bay/slip number
	MaxPassengers       int            `json:"max_passengers"`
	CruisingSpeedKnots  float64        `gorm:"type:decimal(10,2)" json:"cruising_speed_knots"`
	MaxSpeedKnots       float64        `gorm:"type:decimal(10,2)" json:"max_speed_knots"`
	FuelCapacityLiters  float64        `gorm:"type:decimal(10,2)" json:"fuel_capacity_liters"`
	WaterCapacityLiters float64        `gorm:"type:decimal(10,2)" json:"water_capacity_liters"`
	EngineMake          string         `gorm:"size:255" json:"engine_make"`
	EngineModel         string         `gorm:"size:255" json:"engine_model"`
	EngineCount         int            `json:"engine_count"`
	EngineHorsepower    int            `json:"engine_horsepower"`
	EngineHours         float64        `gorm:"type:decimal(10,2)" json:"engine_hours"`
	TransmissionType    string         `gorm:"size:100" json:"transmission_type"`
	HeroImageURL        string         `gorm:"size:500" json:"hero_image_url"`
	GalleryImages       datatypes.JSON `gorm:"type:jsonb" json:"gallery_images"`        // Array of image URLs
	Specifications      datatypes.JSON `gorm:"type:jsonb" json:"specifications"`        // Additional flexible specs
	CreatedAt           time.Time      `json:"created_at"`
	UpdatedAt           time.Time      `json:"updated_at"`
}

func (Yacht) TableName() string {
	return "yachts"
}
