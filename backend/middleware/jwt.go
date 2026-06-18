package middleware

import (
	"net/http"
	"strings"

	"emoney-2fa/services"

	"github.com/gin-gonic/gin"
)

func AuthMiddleware(jwtSvc *services.JWTService) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Authorization header diperlukan",
			})
			return
		}

		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "bearer") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Format token tidak valid. Gunakan: Bearer <token>",
			})
			return
		}

		claims, err := jwtSvc.ValidateToken(parts[1])
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"message": "Token tidak valid atau kadaluarsa",
			})
			return
		}

		c.Set("user_id", claims.UserID)
		c.Set("firebase_uid", claims.FirebaseUID)
		c.Set("email", claims.Email)
		c.Set("role", claims.Role)
		c.Next()
	}
}
