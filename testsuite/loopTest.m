% <LICENSE
%   Copyright (c) 2013, 2014 Jean-Luc Thiffeault
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

classdef loopTest < matlab.unittest.TestCase

  properties
    % Names of some predefined test cases.
    l1
    l2
    b
  end

  methods (TestMethodSetup)
    function createLoop(testCase)
      import braidlab.braid
      import braidlab.loop
      testCase.l1 = loop([1 -1 2 3]);
      testCase.l2 = loop([1 -1 2 3; 2 3 -1 2]);  % two loops
      testCase.b = braid([1 -2 1 -2 1 -2]);
    end
  end

  methods (Test)
    function test_loop_constructor(testCase)
      % A simple loop.
      l = testCase.l1;
      testCase.verifyEqual(l.coords,[1 -1 2 3]);
      testCase.verifyEqual(l.a,[1 -1]);
      testCase.verifyEqual(l.b,[2 3]);
      [a,b] = l.ab;
      testCase.verifyEqual(a,[1 -1]);
      testCase.verifyEqual(b,[2 3]);
      % Create the same loop by specifying a,b.
      testCase.verifyEqual(l.a,braidlab.loop([1 -1],[2 3]).a);
      testCase.verifyEqual(l.b,braidlab.loop([1 -1],[2 3]).b);

      % A row-list of loops.
      l = testCase.l2;
      [c1,c2] = l.coords;
      testCase.verifyEqual(c1,[1 -1 2 3]);
      testCase.verifyEqual(c2,[2 3 -1 2]);

      % The basis of loops used to build loop coordinates.
      l = braidlab.loop(4);
      testCase.verifyEqual(l.coords,[0 0 0 -1 -1 -1]);

      % Trying to create from odd number of columns should error.
      testCase.verifyError(@()braidlab.loop([1 2 3]), ...
                           'BRAIDLAB:loop:loop:oddlength');
      testCase.verifyError(@()braidlab.loop([1 2 3; 4 5 6]), ...
                           'BRAIDLAB:loop:loop:oddlength');
      % Trying to create from different sizes of a,b should error.
      testCase.verifyError(@()braidlab.loop([1 2 3],[4 5]), ...
                           'BRAIDLAB:loop:loop:badsize')
      % Trying to create from different sizes of a,b should error.
      testCase.verifyError(@()braidlab.loop([1 2 3; 1 2 3],[4 5; 4 5]), ...
                           'BRAIDLAB:loop:loop:badsize')
    end

    function test_loopcoords(testCase)
      % Test loop coordinates using various types.
      % This is a method for braid, but essentially uses loops.
      b = braidlab.braid([1 -2 3]);

      l = loopcoords(b);
      testCase.verifyEqual(l.coords,int64([1 -2 1 -2 -2 2]));
      l = loopcoords(b,[],'double');
      testCase.verifyEqual(l.coords,[1 -2 1 -2 -2 2]);
      l = loopcoords(b,[],'int32');
      testCase.verifyEqual(l.coords,int32([1 -2 1 -2 -2 2]));
      l = loopcoords(b,[],'vpi');
      testCase.verifyEqual(l.coords,vpi([1 -2 1 -2 -2 2]));

      l = loopcoords(b,'left');
      testCase.verifyEqual(l.coords,int64([-1 2 -3 0 0 0]));
      l = loopcoords(b,'dehornoy');
      testCase.verifyEqual(l.coords,int64([1 -2 3 0 0 0]));
    end

    function test_loop_length_overflow(testCase)
      % Test that manual iteration of loop coordinates and computation of
      % entropy handles integer overflow well.

      mybraid = testCase.b;

      expEntropy = entropy(mybraid);
      l = loopcoords(mybraid);

      tol = 1e-2; % Let's be generous.

      loopEntropy = @(N)log(minlength(mybraid^N*l)/minlength(l)) / N;

      % This test case is just to ensure that the tolerance set is
      % reasonable.
      Niter = 5;
      err = ['Manual and built-in computations of entropy do not match' ...
             ' at (small) Niter=%d.'];
      testCase.verifyEqual(loopEntropy(Niter), expEntropy, 'AbsTol', tol, ...
                           sprintf(err, Niter));

      % This is the actual overflow test.
      Niter = 100;
      testCase.verifyError(@()loopEntropy(Niter),...
                           'BRAIDLAB:braid:sumg:overflow')
    end
  end
end
