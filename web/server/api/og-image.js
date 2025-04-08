import { createCanvas, loadImage } from "canvas";

export default defineEventHandler(async (event) => {
    const query = getQuery(event);
    const config = useRuntimeConfig();

    const lat = parseFloat(query.lat || 0);
    const lng = parseFloat(query.lng || 0);

    const zoom = 18;

    const width = 1200;
    const height = 630;
    const borderWidth = 12;
    const borderPadding = 20;
    const effectiveBorderSpace = borderPadding + borderWidth / 2;

    const usableWidth = width - effectiveBorderSpace * 2;
    const usableHeight = height - effectiveBorderSpace * 2;

    const imageWidth = Math.floor(usableWidth * 0.45);
    const gapWidth = Math.floor(usableWidth * 0.05);
    const mapWidth = Math.floor(usableWidth * 0.45);
    const mapHeight = Math.floor(usableHeight * 0.65);

    try {
        let hotspotData = [];
        try {
            const response = await $fetch("/api/trash/hotspots", {
                method: "GET",
                baseURL: config.public.apiBaseUrl,
            });

            hotspotData = response.data || [];
        } catch (error) {
            console.error("Failed to fetch hotspots:", error);
        }

        const canvas = createCanvas(width, height);
        const ctx = canvas.getContext("2d");

        ctx.fillStyle = "#ffffff";
        ctx.fillRect(0, 0, width, height);

        const gradient = ctx.createLinearGradient(0, 0, 0, height);
        gradient.addColorStop(0, "#f8fafc");
        gradient.addColorStop(1, "rgba(20, 184, 166, 0.1)");
        ctx.fillStyle = gradient;
        ctx.fillRect(0, 0, width, height);

        ctx.strokeStyle = "rgba(20, 184, 166, 0.3)";
        ctx.lineWidth = borderWidth;
        ctx.strokeRect(
            borderPadding,
            borderPadding,
            width - borderPadding * 2,
            height - borderPadding * 2
        );

        const infoIX = effectiveBorderSpace;
        const infoIY = (height - mapHeight) / 2;
        const mapX = infoIX + imageWidth + gapWidth;
        const mapY = infoIY;

        try {
            const infoImage = await loadImage(
                "https://res.cloudinary.com/dmvdbpyqk/image/upload/v1744096384/style-removebg-preview_cuiwhb.png"
            );

            const infoImageAspectRatio = infoImage.width / infoImage.height;
            let infoImageHeight = mapHeight;
            let infoImageWidth = infoImageHeight * infoImageAspectRatio;

            if (infoImageWidth > imageWidth) {
                infoImageWidth = imageWidth * 0.9;
                infoImageHeight = infoImageWidth / infoImageAspectRatio;
            }

            const centeredinfoIX = infoIX + (imageWidth - infoImageWidth) / 2;
            const centeredinfoIY = infoIY + (mapHeight - infoImageHeight) / 2;

            ctx.drawImage(
                infoImage,
                centeredinfoIX,
                centeredinfoIY,
                infoImageWidth,
                infoImageHeight
            );
        } catch (e) {
            console.error("Error loading infoImage image:", e);
        }

        const getSeverityColor = (severity, opacity = 0.6) => {
            const colors = {
                1: `rgba(0, 255, 0, ${opacity})`,
                2: `rgba(144, 238, 144, ${opacity})`,
                3: `rgba(255, 255, 0, ${opacity})`,
                4: `rgba(255, 165, 0, ${opacity})`,
                5: `rgba(255, 0, 0, ${opacity})`,
            };
            return colors[severity] || `rgba(200, 200, 200, ${opacity})`;
        };

        try {
            const googleMapsKey = config.public.googleMapsApiKey;

            if (googleMapsKey) {
                const mapUrl = `https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=${zoom}&size=${mapWidth}x${mapHeight}&key=${googleMapsKey}`;
                const mapImage = await loadImage(mapUrl);
                ctx.drawImage(mapImage, mapX, mapY, mapWidth, mapHeight);

                // Map border
                ctx.strokeStyle = "#e2e8f0";
                ctx.lineWidth = 2;
                ctx.strokeRect(mapX, mapY, mapWidth, mapHeight);

                if (hotspotData && hotspotData.length > 0) {
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

                    const mapLat = lat;
                    const mapLng = lng;
                    const pixelX = lngToX(mapLng);
                    const pixelY = latToY(mapLat);

                    hotspotData.forEach((hotspot) => {
                        const hotspotLat = hotspot.latGroup;
                        const hotspotLng = hotspot.lngGroup;

                        if (!hotspotLat || !hotspotLng) return;

                        const hotspotPixelX = lngToX(hotspotLng);
                        const hotspotPixelY = latToY(hotspotLat);

                        const relativeX =
                            (mapWidth *
                                (hotspotPixelX - pixelX + mapWidth / 2)) /
                            mapWidth;
                        const relativeY =
                            (mapHeight *
                                (hotspotPixelY - pixelY + mapHeight / 2)) /
                            mapHeight;

                        if (
                            relativeX >= 0 &&
                            relativeX <= mapWidth &&
                            relativeY >= 0 &&
                            relativeY <= mapHeight
                        ) {
                            const radius =
                                (hotspot.reportCount || 1) * 2 +
                                (hotspot.avgSeverity || 3) * 5;

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

                    // Current location marker
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
                    // Current location marker when no hotspots
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
                ctx.fillRect(mapX, mapY, mapWidth, mapHeight);

                ctx.fillStyle = "#94a3b8";
                ctx.font = "24px Arial, sans-serif";
                ctx.textAlign = "center";
                ctx.fillText(
                    "Map preview unavailable",
                    mapX + mapWidth / 2,
                    mapY + mapHeight / 2
                );

                ctx.fillStyle = "#dc2626";
                ctx.beginPath();
                ctx.arc(
                    mapX + mapWidth / 2,
                    mapY + mapHeight / 2 - 50,
                    10,
                    0,
                    Math.PI * 2
                );
                ctx.fill();
            }
        } catch (mapError) {
            console.error("Error loading map image:", mapError);
        }

        const buffer = canvas.toBuffer("image/png");

        setHeaders(event, {
            "Content-Type": "image/png",
            "Cache-Control": "public, max-age=86400, s-maxage=86400",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET",
        });

        return buffer;
    } catch (error) {
        console.error("Error generating OG image:", error);

        setResponseStatus(event, 500);
        return { error: "Failed to generate image" };
    }
});
