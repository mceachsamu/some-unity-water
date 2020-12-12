inline float4 GetShading (float4 wpos, float4 opos, float4 lightPos, float3 wNorm, float3 viewDir, float4 baseColor, float4 _RimColor, float4 _SpecularColor, float _RimAmount, float _Glossiness)
{

    float4 lightDir = lightPos - wpos;

    if (lightPos.w == 0) {
        //directional
        lightDir = lightPos;
    }

    float NdotL = dot(wNorm , lightDir);
    float intensity = NdotL/3.0;
    float overall = intensity;
    //use hard cuttoffs so we get cell effect
    if (overall < 0.0){
        overall = 0.5;
    }
    if (overall > 0.0){
        overall = 1.5;
    }
    //calculate the specular intensity
    float3 H = normalize(lightPos + viewDir);
    float NdotH = dot(wNorm, H);
    float specIntensity = pow(NdotH * intensity, _Glossiness);

    float specularIntensitySmooth = smoothstep(0.0,1.3, specIntensity);
    float4 specular = specularIntensitySmooth * _SpecularColor;

    //calculate the rim intentity
    float4 rimDot = 1 - dot(viewDir, wNorm);
    float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
    float4 rim = rimIntensity * _RimColor;

    //reduce overall shading when light source is further away
    float dist = smoothstep(0,1.0,1.0/pow(length(lightDir),0.2))*20.0;
    if (lightPos.w == 0) {
        //dont use distance decay on directional light
        dist = 1.0;
    }

    float4 finalColor = (overall + specular + rim)*dist;
    //we arent using the alpha channel for our final shading, so pass
    //through the NdotL value so we can use it for calculating underwater distortion
    //finalColor.a = NdotL;
    finalColor.a = 1.0;

    return finalColor;
}