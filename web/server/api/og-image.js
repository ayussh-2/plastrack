import { createCanvas, loadImage } from "canvas";

export default defineEventHandler(async (event) => {
    const query = getQuery(event);

    // Get parameters from query
    const lat = parseFloat(query.lat || 0);
    const lng = parseFloat(query.lng || 0);
    const severity = parseInt(query.severity || 3);

    // Set up canvas
    const width = 1200;
    const height = 630;

    // Define mapWidth and mapHeight at the top level so they're available in catch blocks
    const mapWidth = 600;
    const mapHeight = 400;

    try {
        // Fetch hotspot data from API
        let hotspotData = [];
        try {
            const response = await $fetch("/api/trash/hotspots", {
                method: "GET",
                baseURL: process.env.API_BASE_URL || "http://localhost:3000",
            });

            hotspotData = response.data || [];
            console.log(`Fetched ${hotspotData.length} hotspots`);
        } catch (error) {
            console.error("Failed to fetch hotspots:", error);
            // Continue with empty hotspot data
        }

        // Create canvas
        const canvas = createCanvas(width, height);
        const ctx = canvas.getContext("2d");

        // Draw background
        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, width, height);

        const gradient = ctx.createLinearGradient(0, 0, 0, height);
        gradient.addColorStop(0, "#f8fafc");
        gradient.addColorStop(1, "rgba(20, 184, 166, 0.1)");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, width, height);

        ctx.strokeStyle = "rgba(20, 184, 166, 0.3)";
        ctx.lineWidth = 12;
        ctx.strokeRect(20, 20, width - 40, height - 40);

        // Function to get severity color with opacity
        const getSeverityColor = (severity, opacity = 0.6) => {
            // Color scheme from green (low) to red (high)
            const colors = {
                1: `rgba(0, 255, 0, ${opacity})`, // Green
                2: `rgba(144, 238, 144, ${opacity})`, // Light green
                3: `rgba(255, 255, 0, ${opacity})`, // Yellow
                4: `rgba(255, 165, 0, ${opacity})`, // Orange
                5: `rgba(255, 0, 0, ${opacity})`, // Red
            };
            return colors[severity] || `rgba(200, 200, 200, ${opacity})`;
        };

        try {
            const googleMapsKey = process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY;
            const zoom = 20;
            const mapX = width - mapWidth - 50;
            const mapY = (height - mapHeight) / 2;

            if (googleMapsKey) {
                // Get a basic map without markers - we'll draw the hotspots ourselves
                const mapUrl = `https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=${zoom}&size=${mapWidth}x${mapHeight}&key=${googleMapsKey}`;
                const mapImage = await loadImage(mapUrl);
                ctx.drawImage(mapImage, mapX, mapY, mapWidth, mapHeight);

                // Draw map border
                ctx.strokeStyle = "#e2e8f0";
                ctx.lineWidth = 2;
                ctx.strokeRect(mapX, mapY, mapWidth, mapHeight);

                // Draw hotspots on the map
                if (hotspotData && hotspotData.length > 0) {
                    // Calculate the pixel position from lat/lng (simplified)
                    const latToY = (lat) => {
                        const latRadian = (lat * Math.PI) / 180;
                        const mercN = Math.log(
                            Math.tan(Math.PI / 4 + latRadian / 2)
                        );
                        const y =
                            (0.5 - mercN / (2 * Math.PI)) *
                            256 *
                            Math.pow(2, zoom);
                        return y;
                    };

                    const lngToX = (lng) => {
                        return ((lng + 180) / 360) * 256 * Math.pow(2, zoom);
                    };

                    // Get the northwest and southeast corners of the map
                    const mapLat = lat;
                    const mapLng = lng;
                    const pixelX = lngToX(mapLng);
                    const pixelY = latToY(mapLat);

                    // Draw each hotspot as a circle
                    hotspotData.forEach((hotspot) => {
                        const hotspotLat = hotspot.latGroup;
                        const hotspotLng = hotspot.lngGroup;

                        // Skip if no valid coordinates
                        if (!hotspotLat || !hotspotLng) return;

                        // Calculate relative position on the map
                        const hotspotPixelX = lngToX(hotspotLng);
                        const hotspotPixelY = latToY(hotspotLat);

                        // Calculate x, y position relative to the map viewport
                        const relativeX =
                            (mapWidth *
                                (hotspotPixelX - pixelX + mapWidth / 2)) /
                            mapWidth;
                        const relativeY =
                            (mapHeight *
                                (hotspotPixelY - pixelY + mapHeight / 2)) /
                            mapHeight;

                        // Only draw if within bounds of the map
                        if (
                            relativeX >= 0 &&
                            relativeX <= mapWidth &&
                            relativeY >= 0 &&
                            relativeY <= mapHeight
                        ) {
                            // Calculate radius based on report count and severity
                            const radius =
                                (hotspot.reportCount || 1) * 2 +
                                (hotspot.avgSeverity || 3) * 5;

                            // Draw circle for hotspot
                            ctx.beginPath();
                            ctx.arc(
                                mapX + relativeX,
                                mapY + relativeY,
                                radius,
                                0,
                                2 * Math.PI
                            );
                            ctx.fillStyle = getSeverityColor(
                                Math.round(hotspot.avgSeverity || 3),
                                0.6
                            );
                            ctx.fill();
                            ctx.strokeStyle = getSeverityColor(
                                Math.round(hotspot.avgSeverity || 3),
                                1
                            );
                            ctx.lineWidth = 2;
                            ctx.stroke();
                        }
                    });

                    // Add a main marker for the exact requested location
                    ctx.beginPath();
                    ctx.arc(
                        mapX + mapWidth / 2,
                        mapY + mapHeight / 2,
                        8,
                        0,
                        2 * Math.PI
                    );
                    ctx.fillStyle = "rgba(255, 255, 255, 0.8)";
                    ctx.fill();
                    ctx.strokeStyle = "#dc2626";
                    ctx.lineWidth = 3;
                    ctx.stroke();
                } else {
                    // If no hotspots, draw a single marker at the specified location
                    ctx.beginPath();
                    ctx.arc(
                        mapX + mapWidth / 2,
                        mapY + mapHeight / 2,
                        8,
                        0,
                        2 * Math.PI
                    );
                    ctx.fillStyle = "rgba(255, 255, 255, 0.8)";
                    ctx.fill();
                    ctx.strokeStyle = "#dc2626";
                    ctx.lineWidth = 3;
                    ctx.stroke();
                }
            } else {
                ctx.fillStyle = "#f1f5f9";
                ctx.fillRect(width - 650, (height - 400) / 2, 600, 400);

                ctx.fillStyle = "#94a3b8";
                ctx.font = "24px Arial, sans-serif";
                ctx.textAlign = "center";
                ctx.fillText(
                    "Map preview unavailable",
                    width - 350,
                    height / 2
                );
                ctx.fillStyle = "#dc2626";
                ctx.beginPath();
                ctx.arc(width - 350, height / 2 - 50, 10, 0, Math.PI * 2);
                ctx.fill();
            }
        } catch (mapError) {
            console.error("Error loading map image:", mapError);
            // Now mapWidth and mapHeight will be defined here
        }

        // Add heading text - adjusted position
        const headingY = height / 3 - 70; // Moved up to create more space
        ctx.font = "bold 48px Arial, sans-serif";
        ctx.fillStyle = "#0f172a"; // slate-900
        ctx.textAlign = "left";
        ctx.fillText("Waste Hotspot Alert", 60, headingY);

        let severityText, severityColor;
        if (severity >= 5) {
            severityText = "Critical (Level 5)";
            severityColor = "#dc2626"; // red-600
        } else if (severity === 4) {
            severityText = "High (Level 4)";
            severityColor = "#f97316"; // orange-500
        } else if (severity === 3) {
            severityText = "Medium (Level 3)";
            severityColor = "#eab308"; // yellow-500
        } else {
            severityText = "Low (Level 1-2)";
            severityColor = "#22c55e"; // green-500
        }

        // Draw severity badge - positioned below the heading with proper spacing
        ctx.fillStyle = severityColor;
        const badgeWidth = 180;
        const badgeHeight = 40;
        const badgeX = 60;
        const badgeY = headingY + 30; // Position below heading with margin
        ctx.beginPath();
        // Using rectangle with arc for rounded corners since roundRect might not be available
        ctx.arc(badgeX + 20, badgeY + 20, 20, Math.PI, 1.5 * Math.PI);
        ctx.lineTo(badgeX + badgeWidth - 20, badgeY);
        ctx.arc(badgeX + badgeWidth - 20, badgeY + 20, 20, 1.5 * Math.PI, 0);
        ctx.lineTo(badgeX + badgeWidth, badgeY + badgeHeight - 20);
        ctx.arc(
            badgeX + badgeWidth - 20,
            badgeY + badgeHeight - 20,
            20,
            0,
            0.5 * Math.PI
        );
        ctx.lineTo(badgeX + 20, badgeY + badgeHeight);
        ctx.arc(
            badgeX + 20,
            badgeY + badgeHeight - 20,
            20,
            0.5 * Math.PI,
            Math.PI
        );
        ctx.closePath();
        ctx.fill();

        ctx.font = "bold 18px Arial, sans-serif";
        ctx.fillStyle = "#ffffff";
        ctx.fillText(severityText, badgeX + 20, badgeY + 27);

        // Draw severity scale - positioned below the badge with proper spacing
        const scaleY = badgeY + badgeHeight + 40; // Position below badge with margin
        const scaleX = 60;
        const dotSize = 28;
        const dotGap = 10;

        ctx.font = "bold 18px Arial, sans-serif";
        ctx.fillStyle = "#475569";
        ctx.fillText("Severity Scale:", scaleX, scaleY - 15);

        const colors = ["#22c55e", "#22c55e", "#eab308", "#f97316", "#dc2626"];
        const labels = ["Low", "Low", "Medium", "High", "Critical"];

        for (let i = 0; i < 5; i++) {
            // Draw circle
            ctx.fillStyle = i + 1 <= severity ? colors[i] : "#e2e8f0";
            ctx.beginPath();
            ctx.arc(
                scaleX + (dotSize + dotGap) * i + dotSize / 2,
                scaleY + dotSize / 2,
                dotSize / 2,
                0,
                Math.PI * 2
            );
            ctx.fill();

            // Draw number
            ctx.fillStyle = i + 1 <= severity ? "#ffffff" : "#94a3b8";
            ctx.font = "bold 14px Arial, sans-serif";
            ctx.textAlign = "center";
            ctx.fillText(
                i + 1,
                scaleX + (dotSize + dotGap) * i + dotSize / 2,
                scaleY + dotSize / 2 + 5
            );

            // Draw label under the circle
            ctx.fillStyle = "#475569";
            ctx.font = "12px Arial, sans-serif";
            ctx.fillText(
                labels[i],
                scaleX + (dotSize + dotGap) * i + dotSize / 2,
                scaleY + dotSize + 15
            );
        }

        // Call to action text - adjusted position
        const ctaY = scaleY + dotSize + 50; // Position below severity scale with margin
        ctx.font = "22px Arial, sans-serif";
        ctx.textAlign = "left";
        ctx.fillStyle = "#475569";
        ctx.fillText("This location requires immediate attention", 60, ctaY);
        ctx.fillText(
            "from authorities. Help keep our environment clean.",
            60,
            ctaY + 30
        );

        // Add a small legend on the map for hotspot circles
        const legendX = width - 220;
        const legendY = (height - mapHeight) / 2 + 20;

        // Draw legend background
        ctx.fillStyle = "rgba(255, 255, 255, 0.8)";
        ctx.fillRect(legendX, legendY, 170, 130);
        ctx.strokeStyle = "#e2e8f0";
        ctx.lineWidth = 1;
        ctx.strokeRect(legendX, legendY, 170, 130);

        // Draw legend title
        ctx.font = "bold 14px Arial, sans-serif";
        ctx.fillStyle = "#475569";
        ctx.textAlign = "left";
        ctx.fillText("Waste Concentration", legendX + 10, legendY + 20);

        // Draw legend items
        const legendItems = [
            { color: "#ff0000", label: "Critical (Level 5)" },
            { color: "#ffa500", label: "High (Level 4)" },
            { color: "#ffff00", label: "Medium (Level 3)" },
            { color: "#90ee90", label: "Low (Level 2)" },
            { color: "#00ff00", label: "Very Low (Level 1)" },
        ];

        legendItems.forEach((item, i) => {
            // Draw circle
            ctx.beginPath();
            ctx.arc(legendX + 20, legendY + 40 + i * 18, 6, 0, 2 * Math.PI);
            ctx.fillStyle = item.color;
            ctx.fill();

            // Draw label
            ctx.font = "12px Arial, sans-serif";
            ctx.fillStyle = "#475569";
            ctx.textAlign = "left";
            ctx.fillText(item.label, legendX + 35, legendY + 44 + i * 18);
        });

        // Convert canvas to buffer
        const buffer = canvas.toBuffer("image/png");

        // Set proper content type
        setHeaders(event, {
            "Content-Type": "image/png",
            "Cache-Control": "public, max-age=86400, s-maxage=86400",
        });

        return buffer;
    } catch (error) {
        console.error("Error generating OG image:", error);

        // Return a fallback image or error response
        setResponseStatus(event, 500);
        return { error: "Failed to generate image" };
    }
});
