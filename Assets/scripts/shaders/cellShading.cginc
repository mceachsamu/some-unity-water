inline float4 GetShading (float4 wpos, float4 opos, float4 lightPos, float3 wNorm, float3 viewDir, float4 baseColor, float4 _RimColor, float4 _SpecularColor, float specularStrength, float _RimAmount, float _Glossiness)
{
    float4 lightDir = lightPos - wpos;

    if (lightPos.w == 0) {
        //directional
        lightDir = lightPos;
    }

    float NdotL = dot(normalize(wNorm), normalize(lightDir));
    float intensity = (NdotL);
    float overall = intensity;
    // use hard cuttoffs so we get cell effect
    // if (overall < 0.5){
    //     overall = 0.5;
    // }
    // if (overall > 0.5){
    //     overall = 1.5;
    // }
    //calculate the specular intensity
    float3 H = normalize(normalize(lightDir) + normalize(viewDir));
    float NdotH = dot(wNorm, H);
    float specIntensity = pow(saturate(NdotH), _Glossiness);

    float specularIntensitySmooth = specIntensity;
    float4 specular = specularIntensitySmooth * _SpecularColor * specularStrength;

    //calculate the rim intensity
    float4 rimDot = 1 - dot(viewDir, wNorm);
    float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimDot);
    float4 rim = rimIntensity * _RimColor;

    //calculate backlighting
    float3 FragToLight = wpos - lightPos;
    if (lightPos.w == 0){
        //directional lighting
        FragToLight = - lightPos;
    }

    float backLighting = dot(normalize(viewDir), -normalize(lightDir - wNorm * 0.05));

    float4 finalColor = (overall + specular + backLighting*2.0);
    //we arent using the alpha channel for our final shading, so pass
    //through the NdotL value so we can use it for calculating underwater distortion
    //finalColor.a = NdotL;
    finalColor.a = 1.0;

    return NdotL*2.0 + 0.5 + specular * specIntensity;
}