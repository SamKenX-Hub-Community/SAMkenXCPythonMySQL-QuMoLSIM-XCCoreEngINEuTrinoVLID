##
## Ampient conditions dens0 = 3.15, temp=3.9;
##
## sigma = 3.16 Å, epsilon/kB=78.2, mass=16
## 
function  _water()

  nloops = 1000; dens0=3.16; temp0 = 298.15/78.2;
  
  cutoff = 2.5; sigma = 1.0; epsilon=1.0; aw=1.0;
  cutoff_sf = 2.9;

  lbond = 0.316; kspring = 68421; 
  angle = 1.97; kangle = 490;
  
  molsim('set', 'cutoff', cutoff_sf);
  molsim('set', 'timestep', 0.0005);
  molsim('set', 'exclusion', 'molecule'); 

  molsim('set', 'omp', 4);
	 
  molsim('load', 'xyz', 'water.xyz');
  molsim('load', 'top', 'water.top');
  
  m=0;
  for n=1:nloops
    
    molsim('reset')
    
    molsim('calcforce', 'lj', 'OO', cutoff, sigma, epsilon, aw);
    molsim('calcforce', 'coulomb', 'sf', cutoff_sf);
    
    molsim('calcforce', 'bond', 0, lbond, kspring);
    molsim('calcforce', 'angle', 0, angle, kangle);

    molsim('integrate', 'leapfrog');

    molsim('thermostat', 'relax', 'O', temp0, 0.01);
    molsim('thermostat', 'relax', 'H', temp0, 0.01);

    molsim('compress', dens0);

    if rem(n,20)==0
      m = m+1;
      d = molsim('get', 'moldipoles');
      dipoles(m) = mean(sqrt(d(:,1).^2+d(:,2).^2+d(:,3).^2));
    end
    
  endfor

  lbonds = molsim('get', 'bondlengths');
  angels = molsim('get', 'angles');

  save water.mat dipoles lbonds angels;
  
endfunction
