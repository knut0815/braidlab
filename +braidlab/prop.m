function [varargout] = prop(varargin)
%PROP   Get and set global properties for braidlab.
%   PROP('PropertyName',VALUE,...) assigns VALUE to a braidlab property.
%   This property is global to braidlab classes and functions.
%
%   PROP('PropertyName') returns the current value of the property.
%
%   Valid properties and values are (defaults in braces):
%
%   * GenRotDir - The direction of rotation of braid group generators [ {1}
%   | -1 ].  This is the direction of rotation when strings are exchanged by
%   a generator.  A value of 1 corresponds to clockwise, -1 to
%   counterclockwise.
%
%   * GenOverUnder - Whether to plot a positive generator as over/under or
%   under/over [ {true} | false ].  This only affects braid.plot.
%
%   See also BRAID, LOOP.

% <LICENSE
%   Braidlab: a Matlab package for analyzing data using braids
%
%   http://github.com/jeanluct/braidlab
%
%   Copyright (C) 2013-2015  Jean-Luc Thiffeault <jeanluc@math.wisc.edu>
%                            Marko Budisic         <marko@math.wisc.edu>
%
%   This file is part of Braidlab.
%
%   Braidlab is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   Braidlab is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with Braidlab.  If not, see <http://www.gnu.org/licenses/>.
% LICENSE>

import braidlab.util.validateflag

% List the properties here.
persistent genrotdir genoverunder

% Default values.
if isempty(genrotdir), genrotdir = 1; end
if isempty(genoverunder), genoverunder = true; end

if nargin == 0
  % Maybe list all properties by default?
  error('BRAIDLAB:prop:badarg','Need at least one argument.')
end

% One argument means query mode.
if nargin == 1
  flag = lower(varargin{1});
  switch flag
   case {'genrotdir'}
    varargout{1} = genrotdir;
   case {'genoverunder'}
    varargout{1} = genoverunder;
   otherwise
    error('BRAIDLAB:prop:badarg','Unknown string argument.')
  end
  return
end

parser = inputParser;
parser.addParameter('genrotdir', [], @(x) x == 1 || x == -1);
parser.addParameter('genoverunder', [], @(x) x == true || x == false);
parser.parse(varargin{:});
params = parser.Results;

% Do not overwrite arguments that weren't specified (no default values).
if ~isempty(params.genrotdir), genrotdir = params.genrotdir; end
if ~isempty(params.genoverunder), genoverunder = params.genoverunder; end

if nargout > 0
  error('BRAIDLAB:prop:badnargout', ...
	'No return value assigned when setting a property.')
end
