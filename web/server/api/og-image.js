import { createCanvas, loadImage } from 'canvas';

export default defineEventHandler(async (event) => {
  const query = getQuery(event);
  
  // Get parameters from query
  const lat = parseFloat(query.lat || 0);
  const lng = parseFloat(query.lng || 0);
  const severity = parseInt(query.severity || 3);
  
  // Set up canvas
  const width = 1200;
  const height = 630;
  
  try {
    // Create canvas
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d');
    
    // Draw background
    ctx.fillStyle = '#ffffff';
    ctx.fillRect(0, 0, width, height);
    
    const gradient = ctx.createLinearGradient(0, 0, 0, height);
    gradient.addColorStop(0, '#f8fafc');
    gradient.addColorStop(1, 'rgba(20, 184, 166, 0.1)');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, width, height);
    
    ctx.strokeStyle = 'rgba(20, 184, 166, 0.3)';
    ctx.lineWidth = 12;
    ctx.strokeRect(20, 20, width - 40, height - 40);
    
    
    try {
      const googleMapsKey = process.env.NUXT_PUBLIC_GOOGLE_MAPS_API_KEY;
      const mapWidth = 600;
      const mapHeight = 400;
      const zoom = 15;
      
      if (googleMapsKey) {
        const mapUrl = `https://maps.googleapis.com/maps/api/staticmap?center=${lat},${lng}&zoom=${zoom}&size=${mapWidth}x${mapHeight}&markers=color:red%7C${lat},${lng}&key=${googleMapsKey}`;
        const mapImage = await loadImage(mapUrl);
        ctx.drawImage(mapImage, width - mapWidth - 50, (height - mapHeight) / 2, mapWidth, mapHeight);
        
        ctx.strokeStyle = '#e2e8f0';
        ctx.lineWidth = 2;
        ctx.strokeRect(width - mapWidth - 50, (height - mapHeight) / 2, mapWidth, mapHeight);
      } else {
        ctx.fillStyle = '#f1f5f9';
        ctx.fillRect(width - 650, (height - 400) / 2, 600, 400);
        
        ctx.fillStyle = '#94a3b8';
        ctx.font = '24px Arial, sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('Map preview unavailable', width - 350, height / 2);
        ctx.fillStyle = '#dc2626';
        ctx.beginPath();
        ctx.arc(width - 350, height / 2 - 50, 10, 0, Math.PI * 2);
        ctx.fill();
      }
    } catch (mapError) {
      console.error('Error loading map image:', mapError);
      // Continue without map if it fails to load
    }
    
    // Add heading text - adjusted position
    const headingY = height / 3 - 70; // Moved up to create more space
    ctx.font = 'bold 48px Arial, sans-serif';
    ctx.fillStyle = '#0f172a'; // slate-900
    ctx.textAlign = 'left';
    ctx.fillText('Waste Hotspot Alert', 60, headingY);
    
    let severityText, severityColor;
    if (severity >= 5) {
      severityText = 'Critical (Level 5)';
      severityColor = '#dc2626'; // red-600
    } else if (severity === 4) {
      severityText = 'High (Level 4)';
      severityColor = '#f97316'; // orange-500
    } else if (severity === 3) {
      severityText = 'Medium (Level 3)';
      severityColor = '#eab308'; // yellow-500
    } else {
      severityText = 'Low (Level 1-2)';
      severityColor = '#22c55e'; // green-500
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
    ctx.arc(badgeX + badgeWidth - 20, badgeY + badgeHeight - 20, 20, 0, 0.5 * Math.PI);
    ctx.lineTo(badgeX + 20, badgeY + badgeHeight);
    ctx.arc(badgeX + 20, badgeY + badgeHeight - 20, 20, 0.5 * Math.PI, Math.PI);
    ctx.closePath();
    ctx.fill();
    
    ctx.font = 'bold 18px Arial, sans-serif';
    ctx.fillStyle = '#ffffff';
    ctx.fillText(severityText, badgeX + 20, badgeY + 27);
    
    // Draw severity scale - positioned below the badge with proper spacing
    const scaleY = badgeY + badgeHeight + 40; // Position below badge with margin
    const scaleX = 60;
    const dotSize = 28;
    const dotGap = 10;
    
    ctx.font = 'bold 18px Arial, sans-serif';
    ctx.fillStyle = '#475569';
    ctx.fillText('Severity Scale:', scaleX, scaleY - 15);
    
    const colors = ['#22c55e', '#22c55e', '#eab308', '#f97316', '#dc2626'];
    const labels = ['Low', 'Low', 'Medium', 'High', 'Critical'];
    
    for (let i = 0; i < 5; i++) {
      // Draw circle
      ctx.fillStyle = i + 1 <= severity ? colors[i] : '#e2e8f0';
      ctx.beginPath();
      ctx.arc(scaleX + (dotSize + dotGap) * i + dotSize/2, scaleY + dotSize/2, dotSize/2, 0, Math.PI * 2);
      ctx.fill();
      
      // Draw number
      ctx.fillStyle = i + 1 <= severity ? '#ffffff' : '#94a3b8';
      ctx.font = 'bold 14px Arial, sans-serif';
      ctx.textAlign = 'center';
      ctx.fillText(i + 1, scaleX + (dotSize + dotGap) * i + dotSize/2, scaleY + dotSize/2 + 5);
      
      // Draw label under the circle
      ctx.fillStyle = '#475569';
      ctx.font = '12px Arial, sans-serif';
      ctx.fillText(labels[i], scaleX + (dotSize + dotGap) * i + dotSize/2, scaleY + dotSize + 15);
    }
    
    // Call to action text - adjusted position
    const ctaY = scaleY + dotSize + 50; // Position below severity scale with margin
    ctx.font = '22px Arial, sans-serif';
    ctx.textAlign = 'left';
    ctx.fillStyle = '#475569';
    ctx.fillText('This location requires immediate attention', 60, ctaY);
    ctx.fillText('from authorities. Help keep our environment clean.', 60, ctaY + 30);
  
    
    // Convert canvas to buffer
    const buffer = canvas.toBuffer('image/png');
    
    // Set proper content type
    setHeaders(event, {
      'Content-Type': 'image/png',
      'Cache-Control': 'public, max-age=86400, s-maxage=86400'
    });
    
    return buffer;
  } catch (error) {
    console.error('Error generating OG image:', error);
    
    // Return a fallback image or error response
    setResponseStatus(event, 500);
    return { error: 'Failed to generate image' };
  }
});