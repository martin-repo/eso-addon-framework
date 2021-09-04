--[[
This file was extracted by 'EsoLuaGenerator' at '2021-09-04 16:42:28' using the latest game version.
NOTE: This file should only be used as IDE support; it should NOT be distributed with addons!

****************************************************************************
           CONTENTS OF THIS FILE IS COPYRIGHT ZENIMAX MEDIA INC.
****************************************************************************
]]



function zo_setToIdentityMatrix33(m)
    m._11 = 1
    m._12 = 0
    m._13 = 0
    m._21 = 0
    m._22 = 1
    m._23 = 0
    m._31 = 0
    m._32 = 0
    m._33 = 1
end

function zo_setToRotationMatrix2D(m, radians)
    local cosResult = math.cos(radians)
    local sinResult = math.sin(radians)

    m._11 = cosResult
    m._12 = sinResult
    m._13 = 0
    m._21 = -sinResult
    m._22 = cosResult
    m._23 = 0
    m._31 = 0
    m._32 = 0
    m._33 = 1
end

function zo_setToTranslationMatrix2D(m, x, y)
    m._11 = 1
    m._12 = 0
    m._13 = x
    m._21 = 0
    m._22 = 1
    m._23 = -y
    m._31 = 0
    m._32 = 0
    m._33 = 1
end

function zo_setToScaleMatrix2D(m, scale)
    m._11 = scale
    m._12 = 0
    m._13 = 0
    m._21 = 0
    m._22 = scale
    m._23 = 0
    m._31 = 0
    m._32 = 0
    m._33 = 1
end

function zo_invertMatrix33(m, result)
    local determinant = m._11 * (m._22 * m._33 - m._32 * m._23) -
                        m._12 * (m._21 * m._33 - m._23 * m._31) +
                        m._13 * (m._21 * m._32 - m._22 * m._31)
    local inverseDeterminant = 1 / determinant

    -- store values in locals so we can reuse m as our result matrix: this way we aren't editing the input as we record our output
    local _11 = (m._22 * m._33 - m._32 * m._23) * inverseDeterminant
    local _12 = (m._13 * m._32 - m._12 * m._33) * inverseDeterminant
    local _13 = (m._12 * m._23 - m._13 * m._22) * inverseDeterminant
    local _21 = (m._23 * m._31 - m._21 * m._33) * inverseDeterminant
    local _22 = (m._11 * m._33 - m._13 * m._31) * inverseDeterminant
    local _23 = (m._21 * m._13 - m._11 * m._23) * inverseDeterminant
    local _31 = (m._21 * m._32 - m._31 * m._22) * inverseDeterminant
    local _32 = (m._31 * m._12 - m._11 * m._32) * inverseDeterminant
    local _33 = (m._11 * m._22 - m._21 * m._12) * inverseDeterminant

    result._11 = _11
    result._12 = _12
    result._13 = _13
    result._21 = _21
    result._22 = _22
    result._23 = _23
    result._31 = _31
    result._32 = _32
    result._33 = _33
end

function zo_matrixMultiply33x33(a, b, result)
    -- store values in locals so we can reuse a or b as our result matrix: this way we aren't editing the input as we record our output
    local _11 = a._11 * b._11 + a._12 * b._21 + a._13 * b._31
    local _12 = a._11 * b._12 + a._12 * b._22 + a._13 * b._32
    local _13 = a._11 * b._13 + a._12 * b._23 + a._13 * b._33
    local _21 = a._21 * b._11 + a._22 * b._21 + a._23 * b._31
    local _22 = a._21 * b._12 + a._22 * b._22 + a._23 * b._32
    local _23 = a._21 * b._13 + a._22 * b._23 + a._23 * b._33
    local _31 = a._31 * b._11 + a._32 * b._21 + a._33 * b._31
    local _32 = a._31 * b._12 + a._32 * b._22 + a._33 * b._32
    local _33 = a._31 * b._13 + a._32 * b._23 + a._33 * b._33

    result._11 = _11
    result._12 = _12
    result._13 = _13
    result._21 = _21
    result._22 = _22
    result._23 = _23
    result._31 = _31
    result._32 = _32
    result._33 = _33
end

function zo_matrixTransformPoint(m, pointX, pointY)
    local outX = m._11 * pointX + m._12 * pointY + m._13
    local outY = m._21 * pointX + m._22 * pointY + m._23
    return outX, outY
end