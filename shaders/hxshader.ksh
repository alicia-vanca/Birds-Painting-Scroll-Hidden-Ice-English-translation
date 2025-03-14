   hxshader      MatrixP                                                                                MatrixV                                                                                MatrixW                                                                             
   TIMEPARAMS                                VertexShader.vs�  uniform mat4 MatrixP;
uniform mat4 MatrixV;
uniform mat4 MatrixW;

attribute vec4 POS2D_UV;
varying vec3 PS_TEXCOORD;


void main(void)
{
	vec3 pos = vec3(POS2D_UV.xy, 0);
    float sp = floor(POS2D_UV.z/2.0);
    vec3 texcoord = vec3(POS2D_UV.z - 2.0*sp, POS2D_UV.w, sp);

    mat4 mtxPVW = MatrixP * MatrixV * MatrixW;
    gl_Position = mtxPVW * vec4(pos.xyz, 1.0);
    PS_TEXCOORD = texcoord;
}

    PixelShader.ps]  #ifdef GL_ES
precision mediump float;
#endif

uniform vec4 TIMEPARAMS;

vec3 color1 = vec3(0.149, 0.141, 0.912);
vec3 color2 = vec3(1, 236/255, 139/255);
// 加个注释试试
void main() {
    vec3 color = vec3(0.0);
    float pct = abs(sin(TIMEPARAMS.x));
    color = mix(color1, color2, pct);
    gl_FragColor = vec4(color, 1.0);
}                    