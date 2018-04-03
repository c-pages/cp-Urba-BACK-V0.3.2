#include "DXUT.h"

// ----------------------------------------------------------
// There are two virtually identical test files to
// show how to use the triangulation function:
// test_triangulation.cpp              <-- This uses floating points
// test_triangulation_integers.cpp     <-- This uses integers
//
// Use only one of those two files in your project.
// ----------------------------------------------------------

// this is the function to find triangles from a list of points:
WORD *BuildTriangleIndexList (void *pointList, float factor, int numberOfInputPoints,
                              int numDimensions, int clockwise, int *numTriangleVertices);

struct SimpleVertex {
    D3DXVECTOR3  Pos;
    D3DXVECTOR4  Color;
};

char g_fillTrianglesAlso;

#define MAX_TEST_POINTS  4000
int g_numTestPoints = 16;     // you can adjust this value as the program is running by pressing i or d

#define MAX_RAND    32000      // The maximum random number, used for scaling the triangles to fit the screen

#define NUM_DIMENSIONS    2
// this test function is useful to displaying 2d points only. The 3d points don't show on the
// screen well because the triangles overlap each other. For 3d triangles, you need to be able to
// rotate the display

static int numTriangleVertices;                                     // this does not need initialization
static int testPointsXY[ MAX_TEST_POINTS * NUM_DIMENSIONS] ;   // to hold a set of random points
static SimpleVertex testvertexes[ MAX_TEST_POINTS ];       // those random points converted to vertexes for display

static ID3D11Buffer *g_pTestVector = NULL;
static ID3D11Buffer *g_pTestVectorIndexBuffer = NULL;   // for drawing filled triangles
static ID3D11Buffer *g_pTriOutlineIndexBuffer = NULL;   // for drawing triangle outlines

void ReleaseD3D_Buffers(void);

// ----------------------------------
void SetupTestVertices(ID3D11Device *pd3dDevice)  {
   SimpleVertex *ptrV;
   int i;
   int *ptrToPoints ;
   float scaleFactor = 1.f / (MAX_RAND * 0.5f);     // the test points are from 0 to MAX_RAND, so scale to 0 to 1.0
   int xyOffset = MAX_RAND / 2;
   float brightness;                             // to make the triangles visually different from one another

   WORD *triangleIndexList;   // this does not need initialization

// create a random set of points to test the triangulation fuction
if (g_numTestPoints > MAX_TEST_POINTS)  g_numTestPoints = MAX_TEST_POINTS;
if (g_numTestPoints < 4)  g_numTestPoints = 4;
ptrToPoints = testPointsXY;
for (i=(g_numTestPoints * NUM_DIMENSIONS); i> 0; i--)  {
   *ptrToPoints++ = rand() % MAX_RAND;
}

// create an list of the triangles that connect those test points
// the input points must be integers, and output list is WORD
triangleIndexList =  BuildTriangleIndexList(
          (void*)testPointsXY,          // An array of random integers between 0 and MAX_RAND
          0,
          g_numTestPoints,       // the number of random points
          NUM_DIMENSIONS,        // 2, because the list is X and Y points, no Z values
          1,
          &numTriangleVertices);

// put those random points into a buffer for display
ptrV = testvertexes;
ptrToPoints = testPointsXY;

for (i = 0; i < g_numTestPoints; i++)  {
   // scale to between -1 and +1 since that all that this tutorial program was designed to show
   ptrV->Pos.x = (float)(*ptrToPoints - xyOffset) * scaleFactor;    ptrToPoints++;
   ptrV->Pos.y = (float)(*ptrToPoints - xyOffset) * scaleFactor;    ptrToPoints++;
   if (NUM_DIMENSIONS == 3)  {
      ptrV->Pos.z = (float)(*ptrToPoints - xyOffset) * scaleFactor;    ptrToPoints++;
   }
   else   ptrV->Pos.z = 0;
   // give the nodes different colors to make it easier to distinguish between the triangles, especially when they are filled
   brightness = (float)i/(float)g_numTestPoints;
   ptrV->Color.x = brightness ;
   ptrV->Color.y = brightness * 0.2f;
   ptrV->Color.z = brightness * 0.6f;

   ptrV->Color.w = 1.f;
   ptrV++;
}

// to show the triangle outlines, create an index list of those vertexes in the format for
// D3D_PRIMITIVE_TOPOLOGY_LINELIST
WORD *lineIndex;
int  l, t;
lineIndex = (WORD*) malloc(numTriangleVertices * 3 * sizeof (WORD));
for (l=0, t=0; t<numTriangleVertices; t += 3)  {
   // Each triangle has 3 lines, so D3D_PRIMITIVE_TOPOLOGY_LINELIST needs 6 vertices
   // Each vertex has to be listed twice
   lineIndex[l] = triangleIndexList[t];      l++;
   lineIndex[l] = triangleIndexList[t+1];    l++;
   lineIndex[l] = triangleIndexList[t+1];    l++;
   lineIndex[l] = triangleIndexList[t+2];    l++;
   lineIndex[l] = triangleIndexList[t+2];    l++;
   lineIndex[l] = triangleIndexList[t];      l++;
}

ReleaseD3D_Buffers();   // from the previous cycle

 // Fill in a buffer description for the triangle vertices
 D3D11_BUFFER_DESC bd;
ZeroMemory( &bd, sizeof(bd) );
 bd.Usage = D3D11_USAGE_DEFAULT;
 bd.ByteWidth = sizeof( SimpleVertex ) * g_numTestPoints  ;
 bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
// Fill in the subresource data
 D3D11_SUBRESOURCE_DATA InitData;
ZeroMemory( &InitData, sizeof(InitData) );
 InitData.pSysMem = testvertexes;
 pd3dDevice->CreateBuffer( &bd, &InitData, &g_pTestVector);

// Fill in a buffer description for filled triangles
ZeroMemory( &bd, sizeof(bd) );
 bd.Usage = D3D11_USAGE_DEFAULT;
 bd.ByteWidth = sizeof( WORD ) * numTriangleVertices; // <---- numTriangleVertices comes from the function
 bd.BindFlags = D3D11_BIND_INDEX_BUFFER;
 bd.CPUAccessFlags = 0;
ZeroMemory( &InitData, sizeof(InitData) );
 InitData.pSysMem = triangleIndexList;      // <---- triangleIndexList is from the function also
 pd3dDevice->CreateBuffer( &bd, &InitData, &g_pTestVectorIndexBuffer );

 // Fill in a buffer description for drawing only the triangle outlines
ZeroMemory( &bd, sizeof(bd) );
 bd.Usage = D3D11_USAGE_DEFAULT;
 bd.ByteWidth = sizeof( WORD ) * numTriangleVertices * 3;   // <---- from the function
 bd.BindFlags = D3D11_BIND_INDEX_BUFFER;
 bd.CPUAccessFlags = 0;
ZeroMemory( &InitData, sizeof(InitData) );
 InitData.pSysMem = lineIndex;
 pd3dDevice->CreateBuffer( &bd, &InitData, &g_pTriOutlineIndexBuffer );

free (triangleIndexList);
free (lineIndex);
}

// ----------------------------------
void DrawTextVertexes(ID3D11DeviceContext* g_pImmediateContext) {
   UINT stride = sizeof( SimpleVertex );
   UINT offset = 0;
if (g_pTestVector == NULL)  return;
g_pImmediateContext->IASetVertexBuffers( 0, 1, &g_pTestVector, &stride, &offset );

if (g_fillTrianglesAlso)  {
   // This will show whether the triangles are clockwise, anti-clockwise, or mixed up
   g_pImmediateContext->IASetIndexBuffer( g_pTestVectorIndexBuffer, DXGI_FORMAT_R16_UINT, 0 );
   g_pImmediateContext->IASetPrimitiveTopology( D3D_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
   g_pImmediateContext->DrawIndexed( numTriangleVertices, 0, 0);   // <---- from the function
}
else  {
   // draw the outlines of triangles
   g_pImmediateContext->IASetIndexBuffer( g_pTriOutlineIndexBuffer, DXGI_FORMAT_R16_UINT, 0 );
   g_pImmediateContext->IASetPrimitiveTopology( D3D_PRIMITIVE_TOPOLOGY_LINELIST );
   g_pImmediateContext->DrawIndexed( numTriangleVertices * 3, 0, 0);
}
};

// ----------------------------------
void ReleaseD3D_Buffers(void) {
if( g_pTestVector ) g_pTestVector->Release();
g_pTestVector = NULL;

if( g_pTestVectorIndexBuffer ) g_pTestVectorIndexBuffer->Release();
g_pTestVectorIndexBuffer = NULL;

if( g_pTriOutlineIndexBuffer ) g_pTriOutlineIndexBuffer->Release();
g_pTriOutlineIndexBuffer = NULL;
}

