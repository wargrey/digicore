#include "nested/version.h"

/////////////////////////////////////////////////////////////////////////////////////////////////// 
__lambda__ double stdc_version_filter() {
    return stdc_version() * 0.01;
}
