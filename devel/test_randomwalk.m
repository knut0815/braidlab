n = 30;
N = 1000;
eps = .01;
domain = 'plane';

rng(0)

tic
X = randomwalk(n,N,eps,domain);
toc

figure(1)
clf, hold on
for p = 1:n
  plot(X(:,1,p),X(:,2,p))
end
switch lower(domain)
 case 'square'
  xx = linspace(0,1,10);
  plot(0*xx,xx,'k','LineWidth',2)
  plot(xx,0*xx,'k','LineWidth',2)
  plot(1+0*xx,xx,'k','LineWidth',2)
  plot(xx,1+0*xx,'k','LineWidth',2)
 case 'disk'
  th = linspace(0,2*pi,200); th = [th 0];
  plot(cos(th),sin(th),'k','LineWidth',2)
end
hold off
axis equal
axis off