--    Copyright Martin Eisengardt 2018 xworlds.eu
--    
--    This file is part of xwos.
--
--    xwos is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    xwos is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with xwos.  If not, see <http://www.gnu.org/licenses/>.

_CMR.class('xwos.modules.third')
.ctor(function(self, clazz, privates, kernel)
    privates.kernel = kernel
end)
.func('preboot', function(self, clazz, privates)
    privates.kernel:debug("preboot third")
end)
.func('boot', function(self, clazz, privates)
    privates.kernel:debug("boot third")
end)