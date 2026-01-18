package services

import (
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

var (
	ErrInvalidAppleToken = errors.New("invalid Apple token")
	ErrAppleKeyNotFound  = errors.New("Apple public key not found")
)

// ApplePublicKey represents Apple's public key from their JWKS endpoint
type ApplePublicKey struct {
	Kty string `json:"kty"`
	Kid string `json:"kid"`
	Use string `json:"use"`
	Alg string `json:"alg"`
	N   string `json:"n"`
	E   string `json:"e"`
}

// AppleJWKS represents Apple's JSON Web Key Set
type AppleJWKS struct {
	Keys []ApplePublicKey `json:"keys"`
}

// AppleTokenClaims represents the claims in an Apple ID token
type AppleTokenClaims struct {
	Issuer         string `json:"iss"`
	Audience       string `json:"aud"`
	Subject        string `json:"sub"` // Unique user identifier from Apple
	Email          string `json:"email"`
	EmailVerified  string `json:"email_verified"`
	IsPrivateEmail string `json:"is_private_email"`
	jwt.RegisteredClaims
}

// AppleSignInService handles Apple Sign In token validation
type AppleSignInService struct {
	clientID   string
	teamID     string
	httpClient *http.Client
	keysCache  *AppleJWKS
	cacheTime  time.Time
}

// NewAppleSignInService creates a new Apple Sign In service
func NewAppleSignInService(clientID, teamID string) *AppleSignInService {
	return &AppleSignInService{
		clientID: clientID,
		teamID:   teamID,
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
	}
}

// ValidateToken validates an Apple ID token and returns the claims
func (s *AppleSignInService) ValidateToken(tokenString string) (*AppleTokenClaims, error) {
	// Parse token without validation first to get the header
	token, _, err := new(jwt.Parser).ParseUnverified(tokenString, &AppleTokenClaims{})
	if err != nil {
		return nil, fmt.Errorf("failed to parse token: %w", err)
	}

	// Get the key ID from the token header
	kid, ok := token.Header["kid"].(string)
	if !ok {
		return nil, ErrInvalidAppleToken
	}

	// Get Apple's public keys
	publicKey, err := s.getApplePublicKey(kid)
	if err != nil {
		return nil, err
	}

	// Parse and validate the token with the public key
	parsedToken, err := jwt.ParseWithClaims(tokenString, &AppleTokenClaims{}, func(token *jwt.Token) (interface{}, error) {
		// Verify signing algorithm
		if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
			return nil, ErrInvalidAppleToken
		}
		return publicKey, nil
	})

	if err != nil {
		return nil, fmt.Errorf("failed to validate token: %w", err)
	}

	claims, ok := parsedToken.Claims.(*AppleTokenClaims)
	if !ok || !parsedToken.Valid {
		return nil, ErrInvalidAppleToken
	}

	// Validate issuer and audience
	if claims.Issuer != "https://appleid.apple.com" {
		return nil, fmt.Errorf("invalid issuer: %s", claims.Issuer)
	}

	if claims.Audience != s.clientID {
		return nil, fmt.Errorf("invalid audience: %s", claims.Audience)
	}

	return claims, nil
}

// getApplePublicKey fetches Apple's public keys and returns the one matching the kid
func (s *AppleSignInService) getApplePublicKey(kid string) (*rsa.PublicKey, error) {
	// Check if we need to refresh the cache (cache for 24 hours)
	if s.keysCache == nil || time.Since(s.cacheTime) > 24*time.Hour {
		if err := s.fetchApplePublicKeys(); err != nil {
			return nil, err
		}
	}

	// Find the key with matching kid
	for _, key := range s.keysCache.Keys {
		if key.Kid == kid {
			return s.convertToRSAPublicKey(&key)
		}
	}

	return nil, ErrAppleKeyNotFound
}

// fetchApplePublicKeys fetches Apple's public keys from their JWKS endpoint
func (s *AppleSignInService) fetchApplePublicKeys() error {
	resp, err := s.httpClient.Get("https://appleid.apple.com/auth/keys")
	if err != nil {
		return fmt.Errorf("failed to fetch Apple keys: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("Apple keys endpoint returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("failed to read response body: %w", err)
	}

	var jwks AppleJWKS
	if err := json.Unmarshal(body, &jwks); err != nil {
		return fmt.Errorf("failed to parse JWKS: %w", err)
	}

	s.keysCache = &jwks
	s.cacheTime = time.Now()

	return nil
}

// convertToRSAPublicKey converts Apple's JWK to an RSA public key
func (s *AppleSignInService) convertToRSAPublicKey(key *ApplePublicKey) (*rsa.PublicKey, error) {
	// Decode the modulus (n)
	nBytes, err := base64.RawURLEncoding.DecodeString(key.N)
	if err != nil {
		return nil, fmt.Errorf("failed to decode modulus: %w", err)
	}

	// Decode the exponent (e)
	eBytes, err := base64.RawURLEncoding.DecodeString(key.E)
	if err != nil {
		return nil, fmt.Errorf("failed to decode exponent: %w", err)
	}

	// Convert to big integers
	n := new(big.Int).SetBytes(nBytes)
	e := new(big.Int).SetBytes(eBytes)

	return &rsa.PublicKey{
		N: n,
		E: int(e.Int64()),
	}, nil
}
